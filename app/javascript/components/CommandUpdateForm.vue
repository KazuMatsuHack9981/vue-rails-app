<template>
  <div id="command-update-form" class="main-center">
    <b-form
      @submit.prevent="submitCommand"
      novalidate
    >
      <b-form-group label="タイトル">
        <b-form-input
          v-model="command.title"
          id="title"
        />
        <!-- <b-form-invalid-feedback>
          コマンドのタイトルを入力してください
        </b-form-invalid-feedback> -->
      </b-form-group>

      <b-form-group label="説明">
        <b-form-textarea
          v-model="command.description"
          id="description"
          rows="3"
          max-rows="6"
        />
        <!-- <b-form-invalid-feedback>
          コマンドの説明を入力してください
        </b-form-invalid-feedback> -->
      </b-form-group>
      
      <b-form-group label="ジャンル">
        <b-form-radio-group
          v-model="command.genre_id"
          id="genre_id"
          :options="genreOptions"
        >
          <!-- <b-form-invalid-feedback :state="stateOf(command.genre_id)">
            コマンドのジャンルを選択してください
          </b-form-invalid-feedback> -->
        </b-form-radio-group>
      </b-form-group>
      
      <b-form-group label="タイプ">
        <b-form-radio-group
          v-model="command.command_type_id"
          id="command_type_id"
          :options="commandTypeOptions"
        >
          <!-- <b-form-invalid-feedback :state="stateOf(command.command_type_id)">
            コマンドのタイプを選択してください
          </b-form-invalid-feedback> -->
        </b-form-radio-group>
      </b-form-group>
              
      <!-- <b-form-group label="Zipファイル">
        <b-form-file
          v-model="command.zipdata"
          id="zipdata"
          accept="application/zip"
          required
          placeholder="ファイルを選択してください"
        >
        </b-form-file>
        <b-form-invalid-feedback :state="stateOf(command.zipdata)">
          投稿するファイルを選択してください
        </b-form-invalid-feedback>
      </b-form-group> -->

      <div class="flex-x-center">
        <b-button
          type="submit"
          variant="outline-primary"
          id="submit-command"
        >
          更新
        </b-button>
      </div>
    </b-form>
  </div>
</template>

<script>
import Axios from "axios"
import {mapState} from "vuex"

export default {
  props: {
    prevCommand: {
      type: Object,
      required: true,
      validator: function(value) {
        return ["id", "genre_id", "command_type_id"].every(
          prop => value.hasOwnProperty(prop)
        )
      }
    },
  },
  data: function() {
    return {
      command: {
        title: "",
        description: "",
        genre_id: null,
        command_type_id: null,
        // zipdata: null
      },
      // validated: false
    }
  },
  computed: {
    ...mapState(["genres", "commandTypes"]),
    genreOptions: function() {
      return this.genres.map(genre => (
        {
          text: genre.name,
          value: genre.id
        }
      ))
    },
    commandTypeOptions: function() {
      return this.commandTypes.map(type => (
        {
          text: type.name,
          value: type.id
        }
      ))
    },
    // stateOf: function() {
    //   const self = this
    //   return function(value) {
    //     return self.validated ? !!value : null
    //   }
    // },
    // zipFileName: function() {
    //   return this.command.zipdata.name
    // }
  },
  created: function() {
    this.command.title = this.prevCommand.title
    this.command.description = this.prevCommand.description
    this.command.genre_id = this.prevCommand.genre_id
    this.command.command_type_id = this.prevCommand.command_type_id
  },
  mounted: function() {
    const token = document.querySelector("meta[name=csrf-token]").getAttribute("content")
    Axios.defaults.headers["X-CSRF-TOKEN"] = token
    // Axios.defaults.headers["content-type"] = "multipart/form-data"
  },
  methods: {
    submitCommand() {
      // this.validated = true
      // const form = document.getElementsByTagName("form")[0]
      // if(form.checkValidity() === false) return;

      const params = new FormData()
      Object.entries(this.command).forEach(([param, value]) =>{
        if(value !== "") params.append(param, value)
      });
      // params.append("filename", this.zipFileName)
      Axios.put(`/api/command/${this.prevCommand.id}`, params).then(res =>{
        document.location.reload()
      }).catch(err => {
        console.log(err)
      })
    }
  }
}
</script>

<style>

</style>