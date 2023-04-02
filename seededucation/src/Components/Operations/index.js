import React, {useState, useEffect} from "react";
import "./Operations.css"
import CampoTextoBotao from "../CampoTextoBotao";
import Conn from '../../connection.ts';
import Botao from "../Botao";
import CampoTexto from "../CampoTexto";
import List from "../List";

var conn = new Conn();

const Operations = () => {
    const [flagInst, isInst] = useState(false);
    const [flagAdmin, isAdmin] = useState(false);

    useEffect(() => { 
        async function obtemDados() {
            await conn.connect();
            isInst(await conn.isAuthorized());
            isAdmin(await conn.isAuthorizedAdmin());
    };
       obtemDados();
    }, []);

    conn.getEthereum().on('accountsChanged', async () => {
        if(await conn.checkWalletConnection()){
            isInst(await conn.isAuthorized());
            isAdmin(await conn.isAuthorizedAdmin());
        }
     })

    const [addAdminValue, setAddAdminValue] = useState("");
    const [removeAdminValue, setRemoveAdminValue] = useState("");
    const [addInstValue, setAddInstValue] = useState("");
    const [removeInstValue, setRemoveInstValue] = useState("");
    const [tokenValue, setTokenValue] = useState("");
    const [tokenAmount, setTokenAmount] = useState("");
    const [tokenURI, setTokenURI] = useState("");
    const [institutionsList, getInstitutionsList] = useState("");
    const [adminsInstitutionsList, getAdminsInstitutionsList] = useState("");


    const getInstList = async () => {
        await conn.getInstitutionsList(institutionsList);
    }

    const getAdminsInstList = async () => {
        await conn.getAdminsInstitutionsList(adminsInstitutionsList);
    }

    const addAdmin = async () => {
        await conn.addAdmin(addAdminValue);
    }

    const removeAdmin = async () => {
        await conn.removeAdmin(removeAdminValue);
    }

    const addInst = async () => {
        await conn.add(addInstValue);
    }

    const removeInst = async () => {
        await conn.remove(removeInstValue);
    }

    const mint = async () => {
        await conn.mint(tokenValue, tokenAmount, tokenURI);
    }

    let inst;
    if (flagInst) {
        inst = <div className='inst'>
                    <h2>Criar projeto</h2>
                    <CampoTexto inputValue={inputvalue => setTokenValue(inputvalue)} label="Valor" placeholder="Digite o valor do token"/>
                    <CampoTexto inputValue={inputvalue => setTokenAmount(inputvalue)} label="Quantidade" placeholder="Digite a quantidade do token"/>
                    <CampoTexto inputValue={inputvalue => setTokenURI(inputvalue)} label="URI" placeholder="Digite a URI do token"/>
                    <Botao submit={mint} name="Cadastrar projeto"/>
                </div>
    }


    let admin;
    if (flagAdmin) {
        admin = <React.Fragment><div className='usuario'>
        <h2>Administradores</h2>
        <CampoTextoBotao inputValue={inputvalue => setAddAdminValue(inputvalue)} submit={addAdmin} label="Adicionar instituição à organização:" placeholder="Endereço" buttonName="Votar para adição"/>
        <CampoTextoBotao inputValue={inputvalue => setRemoveAdminValue(inputvalue)} submit={removeAdmin} label="Remover instituição da organização:" placeholder="Endereço" buttonName="Votar para remoção"/>
    </div>
    <div className='usuario'>
        <h2>Instituições</h2>
        <CampoTextoBotao inputValue={inputvalue => setAddInstValue(inputvalue)} submit={addInst} label="Habilitar instituição:" placeholder="Endereço" buttonName="Votar para adição"/>
        <CampoTextoBotao inputValue={inputvalue => setRemoveInstValue(inputvalue)} submit={removeInst} label="Desabilitar instituição:" placeholder="Endereço" buttonName="Votar para remoção"/>
    </div></React.Fragment>;
    }

    return (
        
        <div className='operacoes'>
        {inst}
        <List></List>
            {admin}
        </div>
    )
}

export default Operations;