<template>
  <div class="hello layout">
    <h1>{{ msg }}</h1>
    <b-table striped hover :items="data" :fields="fields"></b-table>
  </div>
</template>

<script>
import axios from 'axios'
export default {
  props: {
    msg: String
  },
  data () {
    return {
      fields: [
        { key: 'Country', label: 'Country' },
        { key: 'Saccos', label: 'Saccos' },
        { key: 'Deposit', label: 'Deposits' },
        { key: 'Withdrawal', label: 'Withdrawals' },
        { key: 'Net', label: 'Net Gains' }
      ],
      data: []
    }
  },

  created: async function () {
    try {
      const response = await axios.get(`/api/reports/transactions`)
      this.data = response.data
    } catch (error) {
      throw new Error(
        `[Transaction Report] ${error}`
      )
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h3 {
  margin: 40px 0 0;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}

.layout{
  width: 60%;
  margin: 0 auto;
}
</style>
