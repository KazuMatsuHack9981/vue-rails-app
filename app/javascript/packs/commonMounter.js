import Vue from 'vue'

import Vuex from 'vuex'
Vue.use(Vuex)

import { BootstrapVue, IconsPlugin } from 'bootstrap-vue'
Vue.use(BootstrapVue)
Vue.use(IconsPlugin)
import "./custom.scss"

import TurbolinksAdapter from 'vue-turbolinks'
Vue.use(TurbolinksAdapter)

import baseStoreSeed from "../util/store"

export default (rootComponent, dataHandler=(h)=>({}), storeSeed={}) => {
  for(let prop in storeSeed) {
    Object.assign(baseStoreSeed[prop], storeSeed[prop])
  }  
  
  const vueMountListener = () => {
    const vueHook = document.getElementById("vue-hook")
    if(vueHook){
      const data = dataHandler(vueHook)
      Object.assign(baseStoreSeed.state, data)
      const store = new Vuex.Store(baseStoreSeed)

      const vm = new Vue({
        render: h => h(rootComponent),
        store
      }).$mount()
      // document.body.appendChild(vm.$el)
      document.body.replaceChild(vm.$el, vueHook)
    }
  }
  
  document.addEventListener('turbolinks:load', vueMountListener)
}

