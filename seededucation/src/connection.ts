import { ethers } from "ethers";

const Inst_ABI = require('./Inst.json');
const TOKEN_ABI = require('./TOKEN_ABI.json');
const OP_ABI = require('./OP_ABI.json');

declare global {
    interface Window {
        ethereum:any;
    }
}

type Network = {
    name: string;
    chainId: number;
    instAddress: string;
    tokenAddress: string;
    opAddress: string;
}

const CELO: Network = {name: 'Celo', chainId: 44787, instAddress: '0xFE8bf228A21B77e1Eb1F10ebeFC206F35f2A0048', tokenAddress: '0x3ab70964CfC7dba746d4426513dAc121e1a52d68', opAddress: '0x83e18878D33Bfa96311798C7f5D9c1E7792A099A'}

export default class Conn {
    private instSCConnected: any;
    private tokenSCConnected: any;
    private opSCConnected: any;
    private ethereum: any;
    private provider: any;
    private signer: any;
    private network: Network;

    constructor(){
        this.ethereum = window.ethereum;
    }

    public async connect() {
        try {
            await this.ethereum.request({ method: 'eth_requestAccounts' });
            this.provider = new ethers.providers.Web3Provider(this.ethereum);
            this.signer = await this.provider.getSigner();
            this.network = CELO;
            let instSmartContract = new ethers.Contract(this.network.instAddress, Inst_ABI, this.signer);
            this.instSCConnected = instSmartContract.connect(this.signer);
            let tokenSmartContract = new ethers.Contract(this.network.tokenAddress, TOKEN_ABI, this.signer);
            this.tokenSCConnected = tokenSmartContract.connect(this.signer);
            let opSmartContract = new ethers.Contract(this.network.opAddress, OP_ABI, this.signer);
            this.opSCConnected = opSmartContract.connect(this.signer);
        } catch (error) {
            console.error(error);
        }
    }

    public getEthereum() {
        return this.ethereum;
    }

    public async checkWalletConnection() {
        return (await this.ethereum.request({ method: 'eth_accounts' })).length > 0 ? true : false;
    }

    public getProvider() {
        return this.provider;
    }

    public async isNetworkConnected(){
        if ((await this.provider.getNetwork()).chainId === this.network.chainId) {
          return true;
        } else {
          return false;
        }
    }

    public async isAuthorized() {
        return await this.instSCConnected.isAuthorized(await this.signer.getAddress());
    }

    public async isAuthorizedAdmin() {
        return await this.instSCConnected.isAuthorizedAdmin(await this.signer.getAddress());
    }

    public async getInstitutionsList() {
        return await this.instSCConnected.getInstitutionsList();
    }

    public async getAdminsInstitutionsList() {
        return await this.instSCConnected.getAdminsInstitutionsList();
    }

    public async add(address: string) {
        await this.instSCConnected.add(address);
    }

    public async addAdmin(address: string) {
        await this.instSCConnected.addAdmin(address);
    }

    public async remove(address: string) {
        await this.instSCConnected.remove(address);
    }

    public async removeAdmin(address: string) {
        await this.instSCConnected.removeAdmin(address);
    }

    public async mint(tokenValue: number, tokenAmount:number, tokenURI: string) {
        await this.tokenSCConnected.mint(tokenValue, tokenAmount, tokenURI);
    }

    public async count() {
        return (await this.tokenSCConnected.count()).toNumber();
    }
    /*
    public async tokenTotal() {
        return (await this.tokenSCConnected.tokenTotal()).toNumber();
    }

    public async tokenPrice() {
        return (await this.tokenSCConnected.tokenPrice()).toNumber();
    }

    //public async hashOfDoc() {
        //return await this.tokenSCConnected.hashOfDoc();
    //}*/

    public async buyToken(id: number) {
        let address = await this.tokenSCConnected.TokenCreator(id);
        const options = {value: ethers.utils.parseEther("1.0")};
        console.log(address);
        return await this.opSCConnected.BuyToken(id, address, options);
    }
}