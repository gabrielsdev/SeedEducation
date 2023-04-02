import React, {useState, useEffect} from "react";
import Card from "../Card";
import "./List.css";
import Conn from '../../connection.ts';

var conn = new Conn();

const List = () => {
  
  const [total, getTotal] = useState(0);

  useEffect(() => { 
    async function obtemDados() {
        await conn.connect();
        getTotal(await conn.count());
};
   obtemDados();
}, []);

  let cards = []
    for (let i = 0; i < total; i++) {

      const invest = async () => {
        await conn.obtainMPE1(i);
      }
      cards.push(<Card key={i} submit={invest} name={i}></Card>)
    }

    return (
      <main style={{width:'100%'}}>
        <section>
        <div className="project-list">
          {cards}
        </div>
      </section>
    </main>
    )
}

export default List;