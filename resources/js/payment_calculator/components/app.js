import React, { Component} from 'react'
import JobCard from './jobCard'
import EstimateTheFuture from './estimateTheFuture'

export default class App extends Component {

  constructor(props) {
    super(props);
    this.state = { 
      workspaces: {},
      totalAmount: 0,
      totalHours: 0,
      averageHourRate: 0,
      numberOfDaysWorked: 0,
      numberOfDaysLeftToWork: 0,
    };

    this.handleInputChange = this.handleInputChange.bind(this);
    this.updatePayments = this.updatePayments.bind(this)

  }

  componentDidMount() {
    this.setState({workspaces: this.props.workspaces})
  }

  handleInputChange(event, name) {
    let target = event.target;
    switch (target.name) {
      case 'hours':
        this.state.workspaces[name].totalHours = target.value
        break;
      case 'minutes':
        this.state.workspaces[name].totalMinutes = target.value
        break;
    }
    this.setState({workspaces: this.state.workspaces})
  }

  updatePayments() {
    let workspaces = this.state.workspaces
    let totalHours = 0
    let totalAmount = 0
    for (let key in workspaces) {
      let workspace = workspaces[key]
      let totalWorkspaceHours = workspace.totalHours ? parseInt(workspace.totalHours) : 0
      let totalWorkspaceMinutes = workspace.totalMinutes ? parseInt(workspace.totalMinutes) / 60 : 0
      let workspaceHours = totalWorkspaceHours + totalWorkspaceMinutes
      totalHours += workspaceHours
      totalAmount += (parseFloat(workspace.hourly_rate) * workspaceHours)
    }
    let averageHourRate = totalAmount / totalHours
    let newStateElements = {
      totalHours: totalHours,
      totalAmount: totalAmount.toFixed(2),
      averageHourRate: averageHourRate.toFixed(2)
    }
    this.setState(newStateElements)
  }

  render() {
    const { totalAmount, totalHours, averageHourRate } = this.state
    let workspaceElements = <div>No Workspaces Loaded</div>;
    let workspaceArray = []
    for (let key in this.state.workspaces) {
      workspaceArray.push(this.state.workspaces[key])
    }
    
    if (workspaceArray.length) {
      workspaceElements = workspaceArray.map(workspace => {
        return <JobCard 
          workspace={workspace}
          handleInputChange={this.handleInputChange}
          updatePayments={this.updatePayments}
          key={workspace.name} />
      })
    }

    return <div>
      <div className="columns height-80vh">
        <div className="column is-two-fifths job-list">
            {workspaceElements}
        </div>
        <div className="column is-two-fifths is-offset-one-fifth">
            <div className="tile is-parent is-vertical">
              <article className="tile is-child notification is-dark">
                <h3 className="title color-white">${totalAmount}</h3>
                <h5 className="title is-5 color-white">{totalHours.toFixed(2)} Hours Total</h5>
                <h5 className="title is-5 color-white">~ ${averageHourRate} / hr</h5>
              </article>
              <article className="tile is-child notification is-dark">
                <EstimateTheFuture
                  totalAmount={totalAmount} />
              </article>
            </div>
          </div>
        </div>
    </div>
  }
}