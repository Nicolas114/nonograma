import React from 'react';

/**
 * Componente Square - se encarga de representar cada celda del tablero.
 */
class Square extends React.Component {
    render() {

        //dependiendo el modo de pintado, la celda debe pintarse de una forma u otra
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