var config = {
  props: ["config"],
  template: `
      <div>
        <h4>Spotify Plugin</h4>
          <div class='col-xs-9'>
            <input placeholder="Account name" v-model="account_name_tile" class='form-control'/>
            <label for="widget">Widget</label>
            <input type="checkbox" id="widget" v-model="widget" class='form-control'/>
            <label for="widget_use_artwork_color">Widget use artwork color</label>
            <input type="checkbox" id="widget_use_artwork_color" v-model="widget_use_artwork_color" class='form-control'/>
             
            </div>
      </div>
    `,

  data: () => ({
    advanced: false,
  }),
  computed: {
    account_name_tile: ChildTile.config_value("account_name_tile", ""),
    widget: ChildTile.config_value("widget", false),
    widget_use_artwork_color: ChildTile.config_value(
      "widget_use_artwork_color",
      true
    ),
  },
  methods: {
    onClick: function (evt) {
      // this.$emit('setConfig', 'foo', 'bar');
    },
  },
};

ChildTile.register({
  config: config,
});
