import React from 'react';
import ReactDOM from 'react-dom';
import '../../styles/index.css';
import App from './components/app'
import * as serviceWorker from './serviceWorker';

let workspaceArray = []
for (let key in window.workspaces) {
  workspaceArray.push(window.workspaces[key])
}

ReactDOM.render(
  <App workspaces={workspaceArray} />,
 document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: http://bit.ly/CRA-PWA
serviceWorker.unregister();