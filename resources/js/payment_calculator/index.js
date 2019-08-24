import React from 'react';
import ReactDOM from 'react-dom';
import '../../styles/index.css';
import App from './components/app'
import * as serviceWorker from './serviceWorker';

let workspaces = {}
for (let key in window.workspaces) {
  window.workspaces[key].totalHours = 0;
  window.workspaces[key].totalMinutes = 0;
  workspaces[window.workspaces[key].name] = window.workspaces[key]
}

ReactDOM.render(
  <App workspaces={workspaces} />,
 document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: http://bit.ly/CRA-PWA
serviceWorker.unregister();