import { connect } from 'react-redux'
import Main from './main'

const mapStateToProps = (state, ownProps) => {
  return {
  }
}

const mapDispatchToProps = (dispatch, ownProps) => {
  return {
  }
}

// Connect Redux and render Main.
// Home page includes the props added in this file
// Home page is also the file that will hold all the other main level components
const MainContainer = connect(
  mapStateToProps,
  mapDispatchToProps
)(Main)


export default MainContainer