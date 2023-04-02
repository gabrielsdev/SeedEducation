import './CampoTexto.css'

const CampoTexto = (props) => {

    const valor = (evento) => {
        props.inputValue(evento.target.value)
    }

    return(
        <div className="campo-texto">
            <label>{props.label}</label>
            <input onChange={valor} placeholder={props.placeholder}/>
        </div>
    )
}

export default CampoTexto;