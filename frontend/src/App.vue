<template>
  <div id="app">
    <Report msg="Transaction Report"/>
  </div>
</template>

<script>
import Report from './components/Report.vue'
export default {
  name: 'app',
  components: {
    Report
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
