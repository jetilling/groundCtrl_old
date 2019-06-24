import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux'
import { createStore, applyMiddleware } from 'redux'
import thunkMiddleware from 'redux-thunk';
import '../styles/index.css';
import MainContainer from './components/main_container'
import * as serviceWorker from './serviceWorker';
import { tabzilla } from './reducers/reducer';
import initialState from './initialState'

let store = createStore(tabzilla, initialState, applyMiddleware(thunkMiddleware));

ReactDOM.render(
  <Provider store = {store}>
    <MainContainer />
  </Provider>,
 document.getElementById('root'));

// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: http://bit.ly/CRA-PWA
serviceWorker.unregister();