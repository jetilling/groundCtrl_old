import React, { Component} from 'react'

export default class App extends Component {

  constructor(props) {
    super(props);
    this.state = { 
      workspaces: [],
      totalAmount: 0,
      totalHours: 0,
      averageHourAmount: 0
    };

    this.handleInputChange = this.handleInputChange.bind(this);
    this.updateStateHoursAndAmounts = this.updateStateHoursAndAmounts.bind(this);
  }

  componentDidMount(props) {
    this.setState({workspaces: this.props.workspaces})
  }

  handleInputChange(stateName, hourlyRate, event) {
    let parsedHours;
    switch(stateName) {
      case 'hours':
        parsedHours = parseInt(event.target.value)
        this.updateStateHoursAndAmounts(hourlyRate, parsedHours)
        break;
      case 'minutes':
        parsedHours = parseInt(event.target.value) / 60
        this.updateStateHoursAndAmounts(hourlyRate, parsedHours)
        break;
    }
  }

  updateStateHoursAndAmounts(hourlyRate, parsedHours) {
    let totalHours = this.state.totalHours + parsedHours
    let totalAmount = parseFloat(this.state.totalAmount) + (hourlyRate * parsedHours)
    let averageHourAmount = totalAmount / totalHours
    let newStateElements = {
      totalHours: totalHours,
      totalAmount: totalAmount.toFixed(2),
      averageHourAmount: averageHourAmount.toFixed(2)
    }
    this.setState(newStateElements)
  }

  render() {
    const { totalAmount, totalHours, averageHourAmount } = this.state
    let inputStyle = {
      width: "40%"
    }
    let workspaceElements = this.state.workspaces.map(workspace => {
      return <div className="box" key={workspace.name}>
          <div className="columns">
            <div className="column is-half">
              <h6 className="title is-4">{workspace.name}</h6>
            </div>
            <div className="column is-half">
              <div className="columns">
                <div className="column is-two-fifth is-offset-three-fifths">
                  <h6 className="title is-4">${parseInt(workspace.hourly_rate)}</h6>
                </div>
              </div>
            </div>
            
          </div>
          <div className="columns">
            <div className="column is-two-fifths">
                <div className="field">
                  <label className="label">Hours</label>
                  <div className="control">
                    <input 
                      className="input" 
                      style={inputStyle} 
                      name="hours"
                      onChange={this.handleInputChange.bind(null, 'hours', workspace.hourly_rate)} />
                  </div>
                </div>
              </div>
              <div className="column is-two-fifths">
                <div className="field">
                  <label className="label">Minutes</label>
                  <div className="control">
                    <input 
                      className="input" 
                      style={inputStyle} 
                      name="minutes"
                      onChange={this.handleInputChange.bind(null, 'minutes', workspace.hourly_rate)} />
                  </div>
                </div>
              </div>
          </div>
      </div>
    })

    return <div>
      <div className="columns height-80vh">
        <div className="column is-two-fifths job-list">
            {workspaceElements}
        </div>
        <div className="column is-two-fifths is-offset-one-fifth">
          <div className="tile is-parent">
            <article className="tile is-child notification is-dark">
              <h3 className="title color-white">${totalAmount}</h3>
              <h5 className="title is-5 color-white">{totalHours.toFixed(2)} Hours Total</h5>
              <h5 className="title is-5 color-white">~ ${averageHourAmount} / hr</h5>
            </article>
          </div>
        </div>

      </div>
    </div>
  }
}