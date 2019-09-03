import React, { Component} from 'react'

export default class EstimateTheFuture extends Component {

  constructor(props) {
    super(props);
    this.state = {
      numberOfDaysWorked: 0,
      numberOfDaysLeftToWork: 0,
      estimatedAmount: 0,
      totalAmount: 0,
      error: false,
      errorMessage: ''
    }

    this.handleDaysWorkedChange = this.handleDaysWorkedChange.bind(this);
    this.handleDaysLeftToWorkChange = this.handleDaysLeftToWorkChange.bind(this);
    this.estimate = this.estimate.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    this.setState(nextProps)
  }

  handleDaysWorkedChange(event) {
    this.setState({numberOfDaysWorked: event.target.value})
  }

  handleDaysLeftToWorkChange(event) {
    this.setState({numberOfDaysLeftToWork: event.target.value})
  }

  estimate() {
    const {numberOfDaysWorked, numberOfDaysLeftToWork, totalAmount} = this.state;
    if (numberOfDaysWorked && numberOfDaysLeftToWork) {
      if (parseFloat(totalAmount)) {
        let estimatedAmountPerDay = totalAmount / numberOfDaysWorked;
        let estimatedAmountToBeAdded = estimatedAmountPerDay * numberOfDaysLeftToWork
        this.setState({
          estimatedAmount: parseFloat(totalAmount) + estimatedAmountToBeAdded, 
          estimatedAmountToBeAdded: estimatedAmountToBeAdded,
          error: false, 
          errorMessage: ''
        })
      }
      else {
        this.setState({error: true, errorMessage: 'Total Dollar Amount above cannot be zero'})
      }
    }
    else {
      this.setState({error: false, errorMessage: ''})
    }
  }

  render() {
    const {error, errorMessage, estimatedAmount, estimatedAmountToBeAdded} = this.state
    let errorOccurred = error ? {display:'inline-block'} : {display: 'none'}
    let showResults = estimatedAmount && estimatedAmountToBeAdded ? {display:'inline-block'} : {display: 'none'}

    return <div>
      <h4 className="title color-white">Estimate the Future</h4>
      <div className="columns">
        <div className="column is-two-fifths">
            <div className="field">
              <label className="label color-white">Number of Days Worked</label>
              <div className="control">
                <input 
                  className="input" 
                  name="worked"
                  value={this.state.numberOfDaysWorked}
                  onChange={this.handleDaysWorkedChange}
                  onBlur={this.estimate} />
              </div>
            </div>
          </div>
          <div className="column is-two-fifths">
            <div className="field">
              <label className="label color-white">Number of Days Left to Work</label>
              <div className="control">
                <input 
                  className="input"  
                  name="leftToWork" 
                  value={this.state.numberOfDaysLeftToWork}
                  onChange={this.handleDaysLeftToWorkChange}
                  onBlur={this.estimate} />
              </div>
            </div>
          </div>
      </div>
      <div style={showResults}>
        <h6 className="subtitle color-white">Expect to make about ${estimatedAmountToBeAdded} more</h6>
        <h5 className="title is-5 color-white">For a total of ${estimatedAmount}</h5>
        <h6 style={errorOccurred} className="title is-5 color-white">{ errorMessage}</h6>
      </div>
    </div>
  }

}