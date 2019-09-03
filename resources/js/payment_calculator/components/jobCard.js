import React, { Component} from 'react'

export default class JobCard extends Component {

  constructor(props) {
    super(props);
    this.state = {
      workspace: {},
      totalHours: '',
      totalMinutes: ''
    }

    this.handleHourChange = this.handleHourChange.bind(this);
    this.handleMinuteChange = this.handleMinuteChange.bind(this);
  }

  componentDidMount() {
    this.setState({workspace: this.props.workspace})
  }

  handleHourChange(e) {
    this.props.handleInputChange(e, this.state.workspace.name)
    this.setState({totalHours: e.target.value})
  }

  handleMinuteChange(e) {
    this.props.handleInputChange(e, this.state.workspace.name)
    this.setState({totalMinutes: e.target.value})
  }

  render() {
    const {workspace} = this.state
    let inputStyle = {
      width: "40%"
    }
    return <div className="box">
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
                        value={this.state.totalHours}
                        onChange={this.handleHourChange}
                        onBlur={this.props.updatePayments} />
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
                        value={this.state.totalMinutes}
                        onChange={this.handleMinuteChange}
                        onBlur={this.props.updatePayments} />
                    </div>
                  </div>
                </div>
            </div>
        </div>
  }
}