import React, { Component} from 'react'

export default class App extends Component {

  constructor(props) {
    super(props);
    this.state = { 
      workspaces: {},
      totalAmount: 0,
      totalHours: 0,
      previousTotalHours: 0,
      averageHourAmount: 0,
    };

    this.handleTestInputChange = this.handleTestInputChange.bind(this);
    this.updatePayments = this.updatePayments.bind(this)
  }

  componentDidMount(props) {
    this.setState({workspaces: this.props.workspaces})
  }

  handleTestInputChange(name, event) {
    let target = event.target;
    switch (target.name) {
      case 'hours':
        this.state.workspaces[name].totalHours = target.value
        this.setState({workspaces: this.state.workspaces})
        break;
      case 'minutes':
        this.state.workspaces[name].totalMinutes = target.value
        this.setState({workspaces: this.state.workspaces})
        break;
    }
  }

  updatePayments() {
    let workspaces = this.state.workspaces
    let totalHours = 0
    let totalAmount = 0
    for (let key in workspaces) {
      let workspace = workspaces[key]
      let totalWorkspaceMinutes = workspace.totalMinutes ? parseInt(workspace.totalMinutes) / 60 : 0
      let totalWorkspaceHours = workspace.totalHours ? parseInt(workspace.totalHours) : 0
      let workspaceHours = totalWorkspaceHours + totalWorkspaceMinutes
      totalHours += workspaceHours
      totalAmount += (parseFloat(workspace.hourly_rate) * workspaceHours)
    }
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
    let workspaceElements = <div>No Workspaces Loaded</div>;
    let workspaceArray = []
    for (let key in this.state.workspaces) {
      workspaceArray.push(this.state.workspaces[key])
    }
    
    if (workspaceArray.length) {
      workspaceElements = workspaceArray.map(workspace => {
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
                        value={workspace.totalHours}
                        onChange={this.handleTestInputChange.bind(null, workspace.name)}
                        onBlur={this.updatePayments} />
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
                        value={workspace.totalMinutes}
                        onChange={this.handleTestInputChange.bind(null, workspace.name)}
                        onBlur={this.updatePayments} />
                    </div>
                  </div>
                </div>
                {/* <div className="level is-one-fifths">
                  <button 
                    className="button is-small" 
                    onClick={this.updateStateHoursAndAmounts.bind(null, workspace.hourly_rate, workspace.name)}
                    >Update</button>
                </div> */}
            </div>
        </div>
      })
    }

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