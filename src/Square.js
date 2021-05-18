import React from 'react';

class Square extends React.Component {
    render() {

        var filled_class = "";
        if (this.props.value === '#'){
            filled_class = " painted";
        }
        else if (this.props.value === 'X') {
            filled_class = " cruz";
        }
        
        return (
            <button className={'square' + filled_class} onClick={this.props.onClick}>
                {this.props.value !== '_' ? this.props.value : null}
            </button>
        );
    }

}

export default Square;