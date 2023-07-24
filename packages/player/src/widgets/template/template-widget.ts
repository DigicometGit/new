import { JSX } from "solid-js";

import { ResourceManager } from "@castmill/cache";
import { Observable, forkJoin, from, merge, of } from "rxjs";
import {
  mergeMap,
  map,
  switchMap,
} from "rxjs/operators";
import { TimelineWidget } from "../timeline-widget";

import { render } from "solid-js/web";
import {
  Template,
  TemplateComponent,
  TemplateComponentTypeUnion,
} from "./template";
import { TemplateConfig } from "./binding";

/**
 * Template Widget
 *
 * This widget allows to create a custom widget using a template.
 *
 */

export interface TemplateWidgetOptions {
  name: string;
  template: TemplateComponentTypeUnion;
  config: TemplateConfig;
  fonts?: { url: string; name: string }[];
  medias: string[];
  style: JSX.CSSProperties;
  classes?: string;
}

export class TemplateWidget extends TimelineWidget {
  private fontFaces: { [key: string]: Promise<FontFace> } = {};
  private medias: { [key: string]: string } = {};
  private template: TemplateComponent;

  constructor(
    resourceManager: ResourceManager,
    private opts: TemplateWidgetOptions
  ) {
    super(resourceManager, opts);

    this.template = TemplateComponent.fromJSON(opts.template, resourceManager);
  }

  /**
   *
   * Loads all the required assets by the template, such as
   * fonts, images, etc.
   *
   * @returns
   */
  private load() {
    return forkJoin([this.loadFonts(), this.loadMedias()]);
  }

  private loadFonts() {
    if (!this.opts.fonts) {
      return of("no:fonts");
    }

    return from(this.opts.fonts).pipe(
      mergeMap((font) =>
        from(this.resourceManager.getMedia(font.url)).pipe(
          map((url) => {
            if (!this.fontFaces[font.name]) {
              this.fontFaces[font.name] = this.loadFont(
                font.name,
                url || font.url
              );
            }
            return of(this.fontFaces[font.name]);
          })
        )
      )
    );
  }

  private loadFont(name: string, url: string) {
    const fontFace = new FontFace(name, `url(${url})`);

    return fontFace.load().then((loadedFace) => {
      document.fonts.add(loadedFace);
      return loadedFace;
    });
  }

  private loadMedias() {
    if (!this.opts.medias) {
      return of("no:medias");
    }
    return from(this.opts.medias).pipe(
      mergeMap((url) =>
        from(this.resourceManager.getMedia(url)).pipe(
          map((cachedUrl) => {
            this.medias[url] = cachedUrl || url;
            return of("media:cached");
          })
        )
      )
    );
  }

  async unload() {
    // Note: there is a risk here that we remove a font that is still in use by another widget.
    // We would need to either keep track of the fonts in use or add a unique prefix to the font name.
    // Probably a global font cache would be the best solution.
    const fontFaceSet = document.fonts;
    const fontFacesNames = Object.keys(this.fontFaces);

    for (let i = 0; i < fontFacesNames.length; i++) {
      const fontFaceName = fontFacesNames[i];
      const fontFace = await this.fontFaces[fontFaceName];
      fontFaceSet.delete(fontFace);
      delete this.fontFaces[fontFaceName];
    }
  }

  show(el: HTMLElement, offset: number) {
    // Note: we need to think how data is refreshed when the model changes.
    const basetime = Date.now();

    return this.load().pipe(
      switchMap((x) => {
        if (el.children.length === 0) {
          // Create observable that will emit when the template is ready.
          return new Observable<string>((subscriber) => {
            render(
              () =>
                Template({
                  name: this.opts.name,
                  root: this.opts.template,
                  config: this.opts.config,
                  style: this.opts.style,
                  timeline: this.timeline,
                  medias: this.medias,
                  resourceManager: this.resourceManager,
                  onReady: () => {
                    this.seek(offset + (Date.now() - basetime));
                    subscriber.next("template-widget:shown");
                    subscriber.complete();
                  },
                }),
              el
            );
          });
        }

        // Seek to compensate for the time spent loading the assets.
        this.seek(offset + (Date.now() - basetime));
        return of("template-widget:shown");
      })
    );
  }

  mimeType(): string {
    return "template/widget";
  }

  duration(): number {
    return this.template.resolveDuration(this.medias);
  }
}
