<template>
  <div id="practice-index2">
    <h2>title: {{title}}</h2>
    <p>description: {{description}}</p>
    <p>contents.outer_links:</p>
    <table class="container">
        <tr>
            <th>name</th>
            <th>text</th>
        </tr>
        <tr
            v-for="outerLink in contents.outer_links"
            :key="outerLink.name"
        >
            <td>{{outerLink.name}}</td>
            <td>{{outerLink.text}}</td>
        </tr>
    </table>
    <img :src="require('images/test-img.jpg')" alt="test-img">
    <img :src="testImg2" alt="test-img2">
    <div class="img-holder test-img"></div>
    <!-- ↑ 404 (Not Found) -->
    <div
      class="img-holder"
      :style="{'background-image': `url(${testImg2})`}"
    ></div>
  </div>
</template>

<script>
import testImg2 from "images/test-img2.jpg";

export default {
  data: function() {
    return {
      testImg2
    }
  },
  props: {
    title: {
      type: String,
      default: () => ""
    },
    description: {
      type: String,
      default: () => ""
    },
    contents: {
      type: Object,
      default: () => {}
    }
  }
};
</script>

<style scoped>
.container {
    border-collapse: collapse;
    text-align: center;
}
.container th,
.container td {
    border: 1px black solid;
    padding: 0.5rem;
}
.img-holder {
  width:100px;
  height: 100px;
  border: 1px solid black;
}
.test-img {
  /* background-image: url("images/test-img.jpg");  */
  /* ↑ Uncaught Error: Cannot find module './images/test-img.jpg' */
}
</style>