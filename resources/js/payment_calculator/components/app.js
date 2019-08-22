import React, { Component} from 'react'

export default class App extends Component {

  constructor(props) {
    super(props);
    this.state = { 
      counter: 0 
    };
  }

  render() {
    return <div>
      <div class="columns">
        <div class="column is-three-fifths">
            Hey O'
        </div>
        <div class="column is-two-fifths">
          <div class="tile is-parent">
            <article class="tile is-child notification is-dark">
              <h3 class="title color-white">Results</h3>
            </article>
          </div>
        </div>

      </div>
    </div>
  }
}