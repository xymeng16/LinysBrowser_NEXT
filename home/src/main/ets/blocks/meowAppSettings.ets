import {
  animation_default,
  capsule_bar_height,
  click_effect_default,
  fontSize_Large,
  home_url_default_blank,
  minimum_block_width
} from '../hosts/bunch_of_defaults';
import linysTitleText from '../components/linysTitleText';
import linysText from '../components/linysText';
import bundleManager from '@ohos.bundle.bundleManager';
import {
  ItemRestriction,
  SegmentButton,
  SegmentButtonOptions,
  SegmentButtonTextItem
} from '@ohos.arkui.advanced.SegmentButton';
import meowUAManager from './meowUAManager';
import { bunch_of_user_agents } from '../hosts/bunch_of_user_agents';
import { bunch_of_tabs } from '../hosts/bunch_of_tabs';
import linysCapsuleButton from '../components/linysCapsuleButton';
import { bunch_of_history } from '../hosts/bunch_of_history';
import { sandbox_open } from '../utils/storage_tools';
import woofHistory from '../dialogs/woofHistory';
import { bunch_of_settings } from '../hosts/bunch_of_settings';
import meowSEManager from './meowSEManager';
import linysLink from '../components/linysLink';

@Component
struct meowAppSettings {
  // Functions
  @Link showing_app_settings: boolean;
  @Link settings_title_bar_position: string;
  @Link settings_tabs_style: string;
  @StorageLink('bunch_of_user_agents') bunch_of_user_agents: bunch_of_user_agents = new bunch_of_user_agents();
  @StorageLink('bunch_of_tabs') bunch_of_tabs: bunch_of_tabs = new bunch_of_tabs();
  @StorageLink('bunch_of_history') bunch_of_history: bunch_of_history = new bunch_of_history();
  @StorageLink('bunch_of_settings') bunch_of_settings: bunch_of_settings = new bunch_of_settings();
  // Generals
  @StorageLink('screen_width') screen_width: number = 0;
  @StorageLink('tablet_mode') tablet_mode: boolean = false;
  @Link @Watch('on_open_or_close_panel') show: boolean;
  @StorageLink('animation_response') animation_response: number = 0;
  @StorageLink('animation_damping_coefficient') animation_damping_coefficient: number = 0;
  // Information
  @State versionName: string = "Version Name";
  @State versionNo: number = 0;
  @State history_length: number = this.bunch_of_history.history_list.length;
  // Settings
  @State title_bar_position_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: '  󰀐  ' }, { text: '  󰃐  ' }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.font_color_title'),
    selectedFontColor: $r('app.color.start_window_background')
  })
  @State tabs_style_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.Settings_appearance_tabs_style_vertical') },
      { text: $r('app.string.Settings_appearance_tabs_style_horizontal') }] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.font_color_title'),
    selectedFontColor: $r('app.color.start_window_background')
  })
  @State start_up_page_tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [
      { text: $r('app.string.Settings_start_up_new_tab') },
      { text: $r('app.string.Settings_start_up_home') },
      { text: $r('app.string.Settings_start_up_continue') }
    ] as ItemRestriction<SegmentButtonTextItem>,
    selectedBackgroundColor: $r('app.color.font_color_title'),
    selectedFontColor: $r('app.color.start_window_background')
  })
  @State @Watch('on_title_bar_position_changed') title_bar_position_selected: number[] = [0];
  @State @Watch('on_tabs_style_changed') tabs_style_selected: number[] = [0];
  @State @Watch('on_start_up_page_changed') start_up_page_selected: number[] = [0];
  @Link settings_max_bookmark_suggestions: number;
  @Link settings_max_history_suggestions: number;
  @Link sys_back_to_access_backward: boolean;
  @Link settings_collect_new_history: boolean;
  // Edits
  @State new_tab_url_edit: string = "";
  @State home_url_edit: string = "";
  // Scroll menu
  @State @Watch('scroll_settings_to') settings_scroll_to: number = 0;
  @State scroll_first: number = 0;
  @State scroll_last: number = 0;
  @State menu_text: string[] =
    ['Settings_start_up', 'Settings_general', 'Settings_experience_history', 'Settings_Experience',
      'Settings_appearance', 'Settings_about'];
  // Dialogs
  woofHistory_control: CustomDialogController = new CustomDialogController({
    builder: woofHistory({ showing_settings: this.show }),
    alignment: DialogAlignment.Center,
    cornerRadius: 12,
    width: "90%",
  });
  waterFlow_control: Scroller = new Scroller();

  build() {
    Row() {
      if (this.tablet_mode) {
        menuScrollVertical({
          on_index_first: this.scroll_first,
          on_index_last: this.scroll_last,
          scroll_to_gateway: this.settings_scroll_to,
          menu_text: this.menu_text,
        })
          .margin({ left: 15 })
      }
      Column({ space: 10 }) {
        if (!this.tablet_mode) {
          menuScrollHorizontal({
            on_index_first: this.scroll_first,
            on_index_last: this.scroll_last,
            scroll_to_gateway: this.settings_scroll_to,
            menu_text: this.menu_text,
          })
            .margin({ left: 15, right: 15 })
        }
        WaterFlow({ scroller: this.waterFlow_control }) {
          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_start_up') })
              linysText({ text: $r('app.string.Settings_start_up_page') })
              SegmentButton({
                options: this.start_up_page_tabOptions,
                selectedIndexes: $start_up_page_selected
              })
            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor($r('app.color.start_window_background'))

          } // Start up
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_general') })

              // UA
              linysText({ text: $r('app.string.Settings_general_custom_ua') })
              meowUAManager()

              // UA
              linysText({ text: $r('app.string.Settings_general_custom_search_engine') })
              meowSEManager()

              // New tab URL
              linysText({ text: $r('app.string.Settings_general_new_tab_url') })
              TextInput({
                text: this.new_tab_url_edit,
                placeholder: home_url_default_blank(),
              })
                .onChange((value) => {
                  this.new_tab_url_edit = value;
                })
                .fontWeight(FontWeight.Regular)
                .fontColor($r('app.color.font_color_title'))
                .caretColor($r('app.color.font_color_title'))
                .selectedBackgroundColor($r('app.color.font_color_title'))
                .onSubmit(() => {
                  this.set_new_tab_url_and_kv_store();
                })
                .height(capsule_bar_height())

              linysCapsuleButton({ text: "  󰀻  " })
                .visibility(this.new_tab_url_edit != this.bunch_of_tabs.new_tab_url ? Visibility.Visible :
                Visibility.None)
                .onClick(() => {
                  this.set_new_tab_url_and_kv_store();
                })
                .alignSelf(ItemAlign.End)
                .animation(animation_default())

              // Home URL
              linysText({ text: $r('app.string.Settings_general_home_url') })
              TextInput({
                text: this.home_url_edit,
                placeholder: home_url_default_blank(),
              })
                .onChange((value) => {
                  this.home_url_edit = value;
                })
                .fontWeight(FontWeight.Regular)
                .fontColor($r('app.color.font_color_title'))
                .caretColor($r('app.color.font_color_title'))
                .selectedBackgroundColor($r('app.color.font_color_title'))
                .onSubmit(() => {
                  this.set_home_url_and_kv_store();
                })
                .height(capsule_bar_height())

              linysCapsuleButton({ text: "  󰀻  " })
                .visibility(this.home_url_edit != this.bunch_of_tabs.home_url ? Visibility.Visible : Visibility.None)
                .onClick(() => {
                  this.set_home_url_and_kv_store();
                })
                .alignSelf(ItemAlign.End)
                .animation(animation_default())

            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor($r('app.color.start_window_background'))

          } // General
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {

              linysTitleText({ text: $r('app.string.Settings_experience_history') }) // History

              Row() {
                linysText({ text: $r('app.string.Settings_experience_history_record_new') })
                Blank()
                Toggle({ isOn: this.settings_collect_new_history, type: ToggleType.Switch })
                  .switchPointColor($r('app.color.block_color'))
                  .selectedColor($r('app.color.font_color_title'))
                  .onChange(isOn => {
                    this.settings_collect_new_history = isOn;
                    this.bunch_of_settings.set_setting_value_of_key('settings_collect_new_history', isOn);
                  })
              } // Toggle History
              .width("100%")

              Row({ space: 10 }) {
                linysTitleText({ text: "󰏕 " + this.history_length.toString() })
                Blank()
                linysText({ text: $r('app.string.Settings_experience_history_view') })
                linysCapsuleButton({ text: "  󰀩  " })
                  .onClick(() => {
                    this.woofHistory_control.open();
                  })
              } // History management
              .width("100%")
            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor($r('app.color.start_window_background'))

          } // History
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_Experience') })

              Row() {
                linysText({ text: $r('app.string.Settings_experience_sys_back_to_access_backward'), max_lines: 3 })
                  .layoutWeight(1)
                Toggle({ isOn: this.sys_back_to_access_backward, type: ToggleType.Switch })
                  .switchPointColor($r('app.color.block_color'))
                  .selectedColor($r('app.color.font_color_title'))
                  .onChange(isOn => {
                    this.sys_back_to_access_backward = isOn;
                    this.bunch_of_settings.set_setting_value_of_key('sys_back_to_access_backward', isOn);
                  })
              } // Use sys back
              .width("100%")

              linysText({ text: $r('app.string.Settings_experience_max_bookmark_advice'), max_lines: 2 })
              Row({ space: 5 }) {
                Slider({
                  min: 0,
                  max: 5,
                  value: this.settings_max_bookmark_suggestions,
                  style: SliderStyle.InSet,
                })
                  .layoutWeight(1)
                  .blockColor($r('app.color.start_window_background'))
                  .selectedColor($r('app.color.font_color_title'))
                  .onChange((value) => {
                    this.settings_max_bookmark_suggestions = value;
                    this.bunch_of_settings.set_setting_value_of_key('settings_max_bookmark_suggestions', value);
                  })
                linysText({ text: this.settings_max_bookmark_suggestions.toString() })
                  .margin({ right: 5 })
              } // Slider and display of max_bookmark_suggestions

              linysText({ text: $r('app.string.Settings_experience_max_history_advice'), max_lines: 2 })
              Row({ space: 5 }) {
                Slider({
                  min: 0,
                  max: 5,
                  value: this.settings_max_history_suggestions,
                  style: SliderStyle.InSet,
                })
                  .layoutWeight(1)
                  .blockColor($r('app.color.start_window_background'))
                  .selectedColor($r('app.color.font_color_title'))
                  .onChange((value) => {
                    this.settings_max_history_suggestions = value;
                    this.bunch_of_settings.set_setting_value_of_key('settings_max_history_suggestions', value);
                  })
                linysText({ text: this.settings_max_history_suggestions.toString() })
                  .margin({ right: 5 })
              } // Slider and display of max_history_suggestions

            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor($r('app.color.start_window_background'))

          } // Experience
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_appearance') })
              linysText({ text: $r('app.string.Settings_appearance_title_bar_position') })
              SegmentButton({
                options: this.title_bar_position_tabOptions,
                selectedIndexes: $title_bar_position_selected
              })

              linysText({ text: $r('app.string.Settings_appearance_tabs_style') })
              SegmentButton({
                options: this.tabs_style_tabOptions,
                selectedIndexes: $tabs_style_selected
              })

              linysText({ text: $r('app.string.Settings_appearance_animation_response') })
              Row({ space: 5 }) {
                Slider({
                  min: 1,
                  max: 100,
                  value: this.animation_response,
                  style: SliderStyle.InSet,
                })
                  .layoutWeight(1)
                  .blockColor($r('app.color.start_window_background'))
                  .selectedColor($r('app.color.font_color_title'))
                  .onChange((value) => {
                    this.animation_response = value;
                  })
                  .onTouch(e => {
                    if (e.type == TouchType.Up) {
                      this.bunch_of_settings.set_setting_value_of_key('animation_response', this.animation_response);
                    }
                  })
                linysText({ text: (this.animation_response / 100).toFixed(2) })
                  .margin({ right: 5 })
              } // Slider and display of animation_response

              linysText({ text: $r('app.string.Settings_appearance_animation_damping_coefficient') })
              Row({ space: 5 }) {
                Slider({
                  min: 0,
                  max: 75,
                  value: this.animation_damping_coefficient,
                  style: SliderStyle.InSet,
                })
                  .layoutWeight(1)
                  .blockColor($r('app.color.start_window_background'))
                  .selectedColor($r('app.color.font_color_title'))
                  .onChange((value) => {
                    this.animation_damping_coefficient = value;
                  })
                  .onTouch(e => {
                    if (e.type == TouchType.Up) {
                      this.bunch_of_settings.set_setting_value_of_key('animation_damping_coefficient',
                        this.animation_damping_coefficient);
                    }
                  })
                linysText({ text: (this.animation_damping_coefficient / 100).toFixed(2) })
                  .margin({ right: 5 })
              } // Slider and display of animation damping coefficient
            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor($r('app.color.start_window_background'))

          } // Appearance
          .width("100%")

          FlowItem() {
            Column({ space: 15 }) {
              linysTitleText({ text: $r('app.string.Settings_about') })
              linysText({ text: "（ฅ＾・ﻌ・＾）ฅ  - " + this.versionName + " - " + this.versionNo })
              linysLink({
                will_be_reversed_boolean: this.showing_app_settings,
                text: $r('app.string.About_bilibili'),
                link: "https://space.bilibili.com/678438347",
              })
              linysLink({
                will_be_reversed_boolean: this.showing_app_settings,
                text: $r('app.string.About_GitHub'),
                link: "https://github.com/awaLiny2333/LinysBrowser_NEXT",
              })
              linysLink({
                will_be_reversed_boolean: this.showing_app_settings,
                text: $r('app.string.About_Gitee'),
                link: "https://gitee.com/awa_Liny/LinysBrowser_NEXT",
              })
            }
            .padding(15)
            .alignItems(HorizontalAlign.Start)
            .justifyContent(FlexAlign.Start)
            .width("100%")
            .borderRadius(10)
            .backgroundColor($r('app.color.start_window_background'))

          } // About
          .width("100%")

        } // Bottom Bar of App Settings
        .columnsTemplate("1fr ".repeat(Math.ceil(this.screen_width / minimum_block_width())))
        .rowsGap(10)
        .columnsGap(10)
        .padding({ left: 15, right: 15 })
        .edgeEffect(EdgeEffect.Spring)
        .scrollBar(BarState.Auto)
        .width("100%")
        .layoutWeight(1)
        .animation(animation_default())
        .onScrollIndex((first, last) => {
          this.scroll_first = first;
          this.scroll_last = last;
        })
      }
      .layoutWeight(1)
      .height("100%")
      .animation(animation_default())
    }
    .height(this.show ? "75%" : 0)
    .width("100%")
    .animation(animation_default())
    .onAppear(() => {
      console.log("[Meow][meowAppSettings] App Settings READY")
      this.on_appear();
    })
  }

  // Events

  async on_appear() {
    // Get app version info
    bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION).then((bundleInfo) => {
      this.versionName = bundleInfo.versionName;
      this.versionNo = bundleInfo.versionCode;
    })

    // Get settings of title bar position
    this.settings_title_bar_position =
      await this.bunch_of_settings.get_setting_key('settings_title_bar_position') as string;

    // Get settings of title bar position
    this.settings_tabs_style =
      await this.bunch_of_settings.get_setting_key('settings_tabs_style') as string;

    // Get number of max bookmarks suggestions
    this.settings_max_bookmark_suggestions =
      await this.bunch_of_settings.get_setting_key('settings_max_bookmark_suggestions') as number;

    // Get number of max history suggestions
    this.settings_max_history_suggestions =
      await this.bunch_of_settings.get_setting_key('settings_max_history_suggestions') as number;

    // Get whether to continue to collect new history
    this.settings_collect_new_history =
      await this.bunch_of_settings.get_setting_key('settings_collect_new_history') as boolean;

    // Get whether to use system back to access backward
    this.sys_back_to_access_backward =
      await this.bunch_of_settings.get_setting_key('sys_back_to_access_backward') as boolean;

    let result = await sandbox_open("history.txt");
    if (result as string == "undefined") {
      // no history before
      console.log("[Meow][meowAppSettings] NO HISTORY BEFORE")
    } else {
      this.bunch_of_history.import_string(result as string);
      console.log("[Meow][meowAppSettings] Recovered History, length: " + result.length.toString())
    }
  }

  on_open_or_close_panel() {
    if (this.show) {
      // Open panel
      this.on_panel_open();
    } else {
      // Close panel
      this.on_panel_close();
    }
  }

  on_panel_open() {
    // Sync Data
    if (this.settings_title_bar_position == "top") {
      this.title_bar_position_selected = [0];
    } else {
      this.title_bar_position_selected = [1];
    }
    if (this.settings_tabs_style == "vertical") {
      this.tabs_style_selected = [0];
    } else {
      this.tabs_style_selected = [1];
    }
    if (this.bunch_of_tabs.new_tab_url !== undefined) {
      this.new_tab_url_edit = this.bunch_of_tabs.new_tab_url;
    }
    if (this.bunch_of_tabs.home_url !== undefined) {
      this.home_url_edit = this.bunch_of_tabs.home_url;
    }
    if (this.bunch_of_tabs.start_up !== undefined) {
      let start_up = this.bunch_of_tabs.start_up;
      if (start_up == "new tab") {
        this.start_up_page_selected = [0];
      }
      if (start_up == "home") {
        this.start_up_page_selected = [1];
      }
      if (start_up == "continue") {
        this.start_up_page_selected = [2];
      }
    }
    // Get length properties
    this.history_length = this.bunch_of_history.history_list.length;
  }

  on_panel_close() {

  }

  // On settings changed

  on_title_bar_position_changed() {
    let result: string = "";
    if (this.title_bar_position_selected[0] == 0) {
      result = 'top';
    } else {
      result = 'bottom';
    }
    this.settings_title_bar_position = result;
    this.bunch_of_settings.set_setting_value_of_key('settings_title_bar_position', result);
  }

  on_start_up_page_changed() {
    let result: string = "";
    if (this.start_up_page_selected[0] == 0) {
      result = "new tab";
    } else if (this.start_up_page_selected[0] == 1) {
      result = "home";
    } else {
      result = "continue";
      // Need modify after update
    }
    this.bunch_of_tabs.start_up = result;
    // kv_store_put("start_up_option", result);
    this.bunch_of_settings.set_setting_value_of_key('start_up_option', result);
  }

  on_tabs_style_changed() {
    let result: string = "";
    if (this.tabs_style_selected[0] == 0) {
      result = 'vertical';
    } else {
      result = 'horizontal';
    }
    this.settings_tabs_style = result;
    this.bunch_of_settings.set_setting_value_of_key('settings_tabs_style', result);
  }

  // Operations

  set_new_tab_url_and_kv_store() {
    this.bunch_of_tabs.new_tab_url = this.new_tab_url_edit;
    // kv_store_put("new_tab_url", this.new_tab_url_edit);
    this.bunch_of_settings.set_setting_value_of_key('new_tab_url', this.new_tab_url_edit);
  }

  set_home_url_and_kv_store() {
    this.bunch_of_tabs.home_url = this.home_url_edit;
    // kv_store_put("home_url", this.home_url_edit);
    this.bunch_of_settings.set_setting_value_of_key('home_url', this.home_url_edit);
  }

  scroll_settings_to() {
    this.waterFlow_control.scrollToIndex(this.settings_scroll_to, true);
  }
}

export default meowAppSettings

@Component
struct menuScrollHorizontal {
  @Link on_index_first: number;
  @Link on_index_last: number;
  @Link scroll_to_gateway: number;
  @State menu_text: string[] = [];

  build() {
    Scroll() {
      Row() {
        ForEach(this.menu_text, (item: string, index: number) => {
          menuItem({
            my_text: $r('app.string.'.concat(item)),
            my_index: index,
            on_index_first: this.on_index_first,
            on_index_last: this.on_index_last,
            scroll_to_gateway: this.scroll_to_gateway,
          })
            .backgroundColor(this.on_index_first <= index && index <= this.on_index_last ?
            $r('app.color.font_color_title') : "transparent")
            .borderRadius(this.border_radius(index))
            .animation(animation_default())
        })
      }
    }
    .align(Alignment.End)
    .edgeEffect(EdgeEffect.Spring)
    .width("100%")
    .scrollable(ScrollDirection.Horizontal)
  }

  border_radius(index: number) {
    if (index == this.on_index_first && index == this.on_index_last) {
      return 10;
    }
    if (index == this.on_index_first) {
      let ra: BorderRadiuses = { topLeft: 10, bottomLeft: 10 };
      return ra;
    }
    if (index == this.on_index_last) {
      let ra: BorderRadiuses = { topRight: 10, bottomRight: 10 };
      return ra;
    }
    return 0;
  }
}

@Component
struct menuScrollVertical {
  @Link on_index_first: number;
  @Link on_index_last: number;
  @Link scroll_to_gateway: number;
  @State menu_text: string[] = [];

  build() {
    Scroll() {
      Column() {
        ForEach(this.menu_text, (item: string, index: number) => {
          menuItem({
            my_text: $r('app.string.'.concat(item)),
            my_index: index,
            on_index_first: this.on_index_first,
            on_index_last: this.on_index_last,
            scroll_to_gateway: this.scroll_to_gateway,
          })
            .backgroundColor(this.on_index_first <= index && index <= this.on_index_last ?
            $r('app.color.font_color_title') : "transparent")
            .borderRadius(this.border_radius(index))
            .animation(animation_default())
        })
      }
      .alignItems(HorizontalAlign.End)
    }
    .align(Alignment.Top)
    .edgeEffect(EdgeEffect.Spring)
    .height("100%")
    .scrollable(ScrollDirection.Vertical)
  }

  border_radius(index: number) {
    if (index == this.on_index_first && index == this.on_index_last) {
      return 10;
    }
    if (index == this.on_index_first) {
      let ra: BorderRadiuses = { topLeft: 10, topRight: 10 };
      return ra;
    }
    if (index == this.on_index_last) {
      let ra: BorderRadiuses = { bottomLeft: 10, bottomRight: 10 };
      return ra;
    }
    return 0;
  }
}

@Component
struct menuItem {
  @State my_index: number = 0;
  @State my_text: ResourceStr = "";
  @Link on_index_first: number;
  @Link on_index_last: number;
  @Link scroll_to_gateway: number;

  build() {
    Row() {
      Text(this.my_text)
        .fontColor(this.on_index_first <= this.my_index && this.my_index <= this.on_index_last ?
        $r('app.color.block_color') : $r('app.color.font_color_title'))
        .fontWeight(this.on_index_first <= this.my_index && this.my_index <= this.on_index_last ?
        FontWeight.Medium : FontWeight.Normal)
        .fontSize(fontSize_Large() - 2)
    }
    .clickEffect(click_effect_default())
    .padding(7)
    .animation(animation_default())
    .onClick(() => {
      // this.on_index_first = this.my_index;
      this.scroll_to_gateway = this.my_index;
    })
  }
}