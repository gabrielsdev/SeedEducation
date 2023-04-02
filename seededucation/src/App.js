import logo from './logo.svg';
import './App.css';
import React, {useState, useEffect} from "react";
import Botao from './Components/Botao';
import Conn from './connection.ts';
import Operations from './Components/Operations';

function App() {

  const [flagNetwork, isNetworkConnected] = useState(false);
  const [flagAccount, isMetamaskConnected] = useState(false);
  const [conn, connFunc] = useState(new Conn());
  useEffect(() => {

    
  async function check(){
    isMetamaskConnected(await conn.checkWalletConnection());
  };

   async function connect() {
    await conn.connect();
    connFunc(conn);
    await check();
   };

   conn.getEthereum().on('accountsChanged', async () => {
     await check();
  })

  connect();

    }, [conn])
     


    if(flagAccount){ 
     
      conn.getEthereum().on('chainChanged', () => {
        window.location.reload();
      })


      async function connectionNetwork() {
        isNetworkConnected(await conn.isNetworkConnected());
      };
      connectionNetwork(); 

    }

  var conteudo;
  if(flagNetwork && flagAccount){
    conteudo = 
          <React.Fragment>
            <Operations/>
          </React.Fragment>;
  } else if (!flagAccount) {
    conteudo = 
    <div className="aviso">
      <div>
        <span>Por favor, conecte-se à uma conta antes de continuar!</span>
        <Botao submit={async () => await conn.connect()} name={[<img className="img-metamask" key="img" src='/metamask.png' alt=''></img>, " Conectar"]}></Botao>
      </div>
    </div>;
  } else if (!flagNetwork) {
    conteudo = 
    <div className="aviso">
      <div>
        Por favor, conecte-se à rede Celo e tente novamente!
      </div>
    </div>;
  } 

  return (
    <div style={{ backgroundImage: `url(/chain.jpg)` }} className="App">
      {conteudo}
    </div>
  );
}

export default App;
