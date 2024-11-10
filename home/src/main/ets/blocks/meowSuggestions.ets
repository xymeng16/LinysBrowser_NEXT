import { animation_default } from '../hosts/bunch_of_defaults';
import linysText from '../components/linysText';
import { get_relations } from '../utils/label_link_relation_tools';
import { bunch_of_bookmarks } from '../hosts/bunch_of_bookmarks';
import { bunch_of_history } from '../hosts/bunch_of_history';
import convert from '@ohos/xml_js';
import { rcp } from '@kit.RemoteCommunicationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { xml, util } from '@kit.ArkTS';
import { convertxml } from '@kit.ArkTS';
import { unify_search_input_into_url } from '../utils/url_tools';

@Component
struct meowSuggestions {
  // Environments or settings
  @Prop top_margin: number = 0;
  @Prop bottom_margin: number = 0;
  @StorageProp('screen_height') screen_height: number = 0;
  @State content_height: number = 0;
  @Prop @Watch('refresh_suggestions') search_input: string = "";
  @Prop is_search_input_typing: boolean;
  // Hosts
  @StorageLink('bunch_of_bookmarks') bunch_of_bookmarks: bunch_of_bookmarks = new bunch_of_bookmarks("meow");
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history();
  // Settings
  @Prop @Watch('refresh_suggestions') settings_max_bookmark_suggestions: number = 5;
  @Prop @Watch('refresh_suggestions') settings_max_history_suggestions: number = 5;
  // Search Engine stuff
  @StorageProp('search_engine') search_engine: string = "";
  @StorageProp('search_suggestion_url') search_suggestion_url?: string = "";
  // Global RCP session
  @StorageLink('rcp_session') rcp_session: rcp.Session = rcp.createSession();
  // Myself
  @State bookmark_suggestions: string[][] = [];
  @State history_suggestions: string[][] = [];
  @State search_suggestions: string[][] = [];
  private scroller: Scroller = new Scroller();

  build() {
    Scroll(this.scroller) {
      Column({ space: 10 }) {
        Column({ space: 8 }) {
          ForEach(this.bookmark_suggestions, (item: string[], index: number) => {
            meowRelation({
              relation: item,
              index: index
            })
          })
        }
        .padding(15)
        .width("100%")
        .backgroundColor($r('app.color.start_window_background'))
        .borderRadius(10)
        .visibility(this.bookmark_suggestions.length > 0 ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

        Column({ space: 8 }) {
          ForEach(this.history_suggestions, (item: string[], index: number) => {
            meowRelation({
              relation: item,
              index: index + this.bookmark_suggestions.length
            })
          })
        }
        .padding(15)
        .width("100%")
        .backgroundColor($r('app.color.start_window_background'))
        .borderRadius(10)
        .visibility(this.history_suggestions.length > 0 ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

        Column({ space: 8 }) {
          ForEach(this.search_suggestions, (item: string[], index: number) => {
            meowRelation({
              relation: item,
              index: index + this.bookmark_suggestions.length + this.history_suggestions.length
            })
          })
        }
        .padding(15)
        .width("100%")
        .backgroundColor($r('app.color.start_window_background'))
        .borderRadius(10)
        .visibility(this.search_suggestions.length > 0 ? Visibility.Visible : Visibility.None)
        .animation(animation_default())

      }
      .onAreaChange((_o, n) => {
        this.content_height = n.height as number;
      })
      // .height(this.get_area_height())
      .alignItems(HorizontalAlign.Start)
      .animation(animation_default())
    }
    .scrollBar(BarState.Off)
    .margin({
      left: 15,
      right: 15,
      top: this.top_margin,
      bottom: this.bottom_margin
    })
    .height(Math.min(this.content_height, 0.4 * this.screen_height))
    .visibility((this.bookmark_suggestions.length + this.history_suggestions.length + this.search_suggestions.length ==
      0) || this.search_input == "" ?
    Visibility.None : this.visible_when_typing())
    .edgeEffect(EdgeEffect.Spring)
    .animation(animation_default())
  }

  visible_when_typing() {
    return this.is_search_input_typing ? Visibility.Visible : Visibility.None
  }

  async refresh_suggestions() {
    if (this.search_input === undefined) {
      this.bookmark_suggestions = [];
      this.history_suggestions = [];
    } else {
      let label_link_bookmark = this.bunch_of_bookmarks.get_all_plain_label_link();
      this.bookmark_suggestions =
        get_relations(label_link_bookmark, this.search_input, this.settings_max_bookmark_suggestions);

      let label_link_history = this.bunch_of_history.get_plain_history();
      this.history_suggestions =
        get_relations(label_link_history, this.search_input, this.settings_max_history_suggestions);

      // get search suggestions
      let suggestions = await this.get_suggestions();
      if (suggestions !== undefined) {
        this.search_suggestions = suggestions;
      }
    }
  }

  async get_suggestions(): Promise<string[][] | undefined> {
    let result: string[][] | undefined = undefined;
    let url = this.search_suggestion_url?.replace("%s", this.search_input);
    if (url === undefined) {
      return result;
    }
    url = unify_search_input_into_url(url);
    console.info("Getting suggestions from: " + url);
    let response = await this.rcp_session.get(url)
      .catch((err: BusinessError) => {
        console.error("Error when getting suggestions: " + JSON.stringify(err));
        return undefined;
      });
    if (response === undefined) {
      return result;
    }
    if (this.search_engine.includes("google")) { // TODO: refactor this
      result = this.google_suggestion_parser(response);
    } else {
      result = this.bing_suggestion_parser(response);
    }
    console.log("Got suggestions: " + JSON.stringify(result));
    return result;
  }

  google_suggestion_parser(response: rcp.Response): string[][] {
    let result: string[][] = [];
    let options: convertxml.ConvertOptions = {
      trim: false,
      declarationKey: "_declaration",
      instructionKey: "_instruction",
      attributesKey: "_attributes",
      textKey: "_text",
      cdataKey: "_cdata",
      doctypeKey: "_doctype",
      commentKey: "_comment",
      parentKey: "_parent",
      typeKey: "_type",
      nameKey: "_name",
      elementsKey: "_elements"
    };
    let conv: convertxml.ConvertXML = new convertxml.ConvertXML();
    let resObj: object = conv.convertToJSObject(response.toString(), options);
    let resArr: object[] = resObj['_elements'][0]['_elements'];
    if (resArr === undefined) {
      return result;
    }
    for (let i = 0; i < resArr.length; i++) {
      let str: string = resArr[i]['_elements'][0]['_attributes']['data'];
      console.info("suggestion: " + str);
      result[i] = [str, unify_search_input_into_url(str)];
    }
    return result.slice(0, result.length > 5 ? 5 : result.length);
  }

  bing_suggestion_parser(response: rcp.Response): string[][] {
    let result: string[][] = [];
    let options: convertxml.ConvertOptions = {
      trim: false,
      declarationKey: "_declaration",
      instructionKey: "_instruction",
      attributesKey: "_attributes",
      textKey: "_text",
      cdataKey: "_cdata",
      doctypeKey: "_doctype",
      commentKey: "_comment",
      parentKey: "_parent",
      typeKey: "_type",
      nameKey: "_name",
      elementsKey: "_elements"
    };
    let conv: convertxml.ConvertXML = new convertxml.ConvertXML();
    let resObj: object = conv.convertToJSObject(response.toString(), options);
    let resArr: object[] = resObj['_elements'][1]['_elements'][1]['_elements'];
    if (resArr === undefined) {
      return result;
    }
    for (let i = 0; i < resArr.length; i++) {
      let _text: object[] = resArr[i]['_elements'][0]['_elements'];
      let str = '';
      switch (_text.length) {
        case 1: {
          if (_text[0]['_type'] === 'element') {
            str = _text[0]['_elements'][0]['_text'];
          } else {
            str = _text[0]['_text'];
          }
          break;
        }
        case 2: { // both original search input and 'strong' tag included
          str = _text[0]['_text'] + _text[1]['_elements'][0]['_text'];
          break;
        }
      }
      console.info("suggestion: " + str);
      result[i] = [str, unify_search_input_into_url(str)];
    }
    return result.slice(0, result.length > 5 ? 5 : result.length);
  }
}

export default meowSuggestions;

@Component
struct meowRelation {
  @Prop relation: string[] = [];
  @Prop index: number;
  @State offset_y: number = 50;
  @State this_visibility: Visibility = Visibility.Hidden;
  @StorageLink('universal_load_url_gateway') load_url_gateway: string = "";

  build() {
    Column({ space: 2 }) {
      linysText({
        text: this.relation[0].length == 0 ? "　" : this.relation[0]
      })
      linysText({
        text: this.relation[1]
      })
        .opacity(0.7)
    }
    .alignItems(HorizontalAlign.Start)
    .width("100%")
    .visibility(this.this_visibility)
    .offset({ y: this.offset_y })
    .animation(animation_default())
    .onClick(() => {
      this.load_url_gateway = this.relation[1];
    })
    .onAppear(() => {
      setTimeout(() => {
        this.offset_y = 0;
        this.this_visibility = Visibility.Visible;
      }, (this.index) * 60)
    })
  }
}