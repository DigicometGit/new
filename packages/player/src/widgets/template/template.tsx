import { Component, JSX } from "solid-js";
import { ResourceManager } from "@castmill/cache";

import { Item } from "./item";
import { TemplateConfig } from "./binding";
import { GroupComponent } from "./group";
import { TextComponent } from "./text";
import { ImageComponent } from "./image";
import { VideoComponent } from "./video";
import { ListComponent } from "./list";
import { ImageCarouselComponent } from "./image-carousel";
import { LayoutComponent } from "./layout";
import { Timeline } from "./timeline";

export type TemplateComponentTypeUnion =
  | TextComponent
  | ImageComponent
  | VideoComponent
  | ListComponent
  | GroupComponent
  | LayoutComponent
  | ImageCarouselComponent;

export enum TemplateComponentType {
  Template = "template",
  Layout = "layout",
  Text = "text",
  Image = "image",
  Video = "video",
  List = "list",
  Group = "group",
  ImageCarousel = "image-carousel",
}

export class TemplateComponent {
  readonly type: any = TemplateComponentType.Template;
  readonly style: JSX.CSSProperties = {};

  constructor(
    public name: string,
    public opts: any // public config: TemplateConfig, // public component: TemplateComponentTypeUnion
  ) {}

  resolveDuration(medias: { [index: string]: string }): number {
    return 0;
  }

  static fromJSON(
    json: any,
    resourceManager: ResourceManager
  ): TemplateComponent {
    switch (json.type) {
      case TemplateComponentType.Group:
        return GroupComponent.fromJSON(json, resourceManager);
      case TemplateComponentType.List:
        return ListComponent.fromJSON(json, resourceManager);
      case TemplateComponentType.Layout:
        return LayoutComponent.fromJSON(json, resourceManager);
      case TemplateComponentType.Text:
        return TextComponent.fromJSON(json);
      case TemplateComponentType.Image:
        return ImageComponent.fromJSON(json);
      case TemplateComponentType.Video:
        return VideoComponent.fromJSON(json);
      case TemplateComponentType.ImageCarousel:
        return ImageCarouselComponent.fromJSON(json);
      default:
        throw new Error(`Unknown template component type: ${json.type}`);
    }
  }
}

export const Template: Component<{
  name: string;
  root: TemplateComponentTypeUnion;

  style: JSX.CSSProperties;
  timeline: Timeline;
  resourceManager: ResourceManager;

  config: TemplateConfig;
  medias: { [index: string]: string };
  onReady: () => void;
}> = (props) => {
  return (
    <div data-component="template" data-name={props.name} style={props.style}>
      <Item
        config={props.config}
        context={null}
        medias={props.medias}
        component={props.root}
        timeline={props.timeline}
        resourceManager={props.resourceManager}
        onReady={props.onReady}
      />
    </div>
  );
};