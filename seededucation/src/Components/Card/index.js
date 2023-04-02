import Botao from "../Botao";
import "./Card.css"

const Card = (props) => {
    return (
    <div className="project-card">
          <div className="project-card-img">
            <img src="https://via.placeholder.com/300x200" alt="Projeto 5"/>
          </div>
          <div className="project-card-info">
            <h3>{props.name}</h3>
            <p>{props.description}</p>
            <Botao submit={props.submit} name="Investir"></Botao>
          </div>
        </div>
    )
}

export default Card;