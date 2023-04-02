import Botao from '../Botao';
import CampoTexto from '../CampoTexto';
import './CampoTextoBotao.css';

const CampoTextoBotao = (props) => {
    return(
        <div className='campo-texto-botao'>
            <CampoTexto label={props.label} inputValue={props.inputValue} placeholder={props.placeholder}/>
            <Botao name={props.buttonName} classState={props.classState} submit={props.submit}/>
        </div>
    )
}

export default CampoTextoBotao;