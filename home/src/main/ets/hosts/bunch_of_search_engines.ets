export class bunch_of_search_engines {
  default_search_engines: search_engine[] = [ // TODO: move to resources later
    new search_engine("Bing", "https://www.bing.com/search?q=%s", true,
      "https://api.bing.com/qsml.aspx?Market=zh-CN&q=%s"),
    new search_engine("Google", "https://www.google.com/search?q=%s", true,
      "https://clients1.google.com/complete/search?hl=zh&output=toolbar&q=%s"),
    new search_engine("Baidu", "baidu.com/s?wd=%s", true,
      "https://api.bing.com/qsml.aspx?Market=zh-CN&q=%s")
  ];
  list_of_search_engines: search_engine[] = [];

  constructor() {
  }

  add_search_engine(se: search_engine) {
    this.list_of_search_engines.push(se);
  }

  del_search_engine(index: number) {
    index = index - this.default_search_engines.length;
    this.list_of_search_engines.splice(index, 1);
  }

  get_list_of_search_engines() {
    let result: search_engine[] = [];
    result.push(...this.default_search_engines);
    result.push(...this.list_of_search_engines);
    return result;
  }

  get_search_engine(index: number) {
    if (index < this.default_search_engines.length) {
      return this.default_search_engines[index];
    } else {
      return this.list_of_search_engines[index - this.default_search_engines.length];
    }
  }

  export_string() {
    let export_list: string[] = []
    for (let index = 0; index < this.list_of_search_engines.length; index++) {
      let ua: search_engine = this.list_of_search_engines[index];
      export_list.push(ua.label);
      export_list.push(ua.content);
    }
    return export_list.join("\n");
  }

  /**
   * @param imp store string
   * @abstract In default overwrites whatever was in this bunch_of_search_engines
   * */
  import_string(imp: string) {
    // Clear
    this.list_of_search_engines = [];
    if (imp == "") {
      return;
    }
    // Import
    let import_list: string[] = imp.split("\n");
    for (let index = 0; index < import_list.length; index += 2) {
      if (import_list[index] != "") {
        this.add_search_engine(new search_engine(import_list[index], import_list[index+1]));
      }
    }
  }
}

export class search_engine {
  label: string;
  content: string;
  built_in: boolean = false;
  suggest?: string;

  constructor(label: string, content: string, built_in: boolean = false, suggest?: string) {
    this.label = label;
    this.content = content;
    this.built_in = built_in;
    this.suggest = suggest;
  }
}