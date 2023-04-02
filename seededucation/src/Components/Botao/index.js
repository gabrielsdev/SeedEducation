import './Botao.css';

const Botao = (props) => {
    return (
        <button className={props.classState} onClick={props.submit}>{props.name}</button>
    )
}

export default Botao;