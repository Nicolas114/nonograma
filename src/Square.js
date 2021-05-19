import React from 'react';

class Square extends React.Component {
    render() {

        var filled_class = "";
        if (this.props.value === '#'){
            filled_class = " square-painted";
        }
        else if (this.props.value === 'X') {
            filled_class = " square-cruz";
        }
        
        return (
            <button className={'square' + filled_class} onClick={this.props.onClick}>
                {this.props.value !== '_' ? this.props.value : null}
            </button>
        );
    }

}

export default Square;