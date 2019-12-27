import { shallowMount } from '@vue/test-utils'
import Report from '@/components/Report.vue'

describe('HelloWorld.vue', () => {
  it('renders props.msg when passed', () => {
    const msg = 'new message'
    const wrapper = shallowMount(Report, {
      propsData: { msg }
    })
    expect(wrapper.text()).toMatch(msg)
  })
})
