<template>
  <div class="hello layout">
    <h1>{{ msg }}</h1>
    <b-table
      small striped hover
      :items="data"
      :busy="isBusy"
      :fields="fields">
       <b-tfoot>
      <b-tr>
        <b-td colspan="7" variant="secondary" class="text-right">
          Total Rows: <b>5</b>
        </b-td>
      </b-tr>
    </b-tfoot>
    </b-table>
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
      data: [],
      isBusy: false
    }
  },

  created: async function () {
    this.isBusy = true
    try {
      const response = await axios.get(`/api/reports/transactions`)
      this.data = response.data.rows
      const totals = {
        Country: 'Totals',
        Saccos: response.data.total_saccos,
        Deposit: response.data.total_deposits,
        Withdrawal: response.data.total_withdrawals,
        Net: response.data.total_netgains
      }
      this.data.push(totals)
      this.isBusy = false
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
.layout{
  width: 60%;
  margin: 0 auto;
}
</style>
