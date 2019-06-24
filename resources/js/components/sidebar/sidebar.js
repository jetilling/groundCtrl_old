import React from 'react'
import PropTypes from 'prop-types'
import '../../../styles/sidebar.css'

const Sidebar = ({}) =>  {

  return (
    <div>
      <div className="sidebar">
        <div className="sb-header-container">
          <h3>WorkSpaces</h3>
          <button className="sb-add-btn">+</button>
        </div>
        
      </div>
      
    </div>
  )
}

Sidebar.propTypes = {
};

export default Sidebar