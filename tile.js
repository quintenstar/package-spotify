var config = {
  props: ["config"],
  template: `
      <div>
        <h4>Spotify Plugin</h4>
          <div class='col-xs-9'>
            <input placeholder="Account name" v-model="account_name_tile" class='form-control'/>
          </div>


      </div>
    `,

  data: () => ({
    advanced: false,
  }),
  computed: {
    account_name_tile: ChildTile.config_value("account_name_tile", ""),
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
