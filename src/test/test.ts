import { RPSContract } from '../artifacts/RPS.js'
import {
  AccountWallet,
  AccountWalletWithPrivateKey,
  AztecAddress,
  CheatCodes,
  CompleteAddress,
  Contract,
  createPXEClient,
  Fr, getSandboxAccountsWallets,
  PXE,
  TxStatus,
  waitForSandbox,
  Wallet,
} from '@aztec/aztec.js'


const setupSandbox = async () => {
  const { PXE_URL = 'http://localhost:8080' } = process.env
  const pxe = createPXEClient(PXE_URL)
  await waitForSandbox(pxe)
  return pxe
}


function delay(ms: number) {
  return new Promise(resolve => setTimeout(resolve, ms));
}


describe('ZK Contract Tests', async () => {
  let owner: AccountWalletWithPrivateKey
  let _account2: AccountWalletWithPrivateKey
  let _account3: AccountWalletWithPrivateKey
  let testAddress: AztecAddress
  let contractAddress: AztecAddress
  let pxe: PXE;
  let cc: CheatCodes

  async function getTest(wallet: AccountWalletWithPrivateKey, address: AztecAddress) {
    return RPSContract.at(address, wallet);
  }

  describe('Setup', async () => {
    it('Init sandbox', async () => {
      pxe = await setupSandbox();
      [owner, _account2, _account3] = await getSandboxAccountsWallets(pxe);
      const [a] = await pxe.getRegisteredAccounts();
      console.log(owner.getAddress().toString(), a.address.toString());
    });

    it('Deploy test', async function () {
      const test = await RPSContract.deploy(pxe).send().deployed();
      testAddress = test.address;
      console.log(testAddress.toString())
    });
  });

  describe('Test', async () => {
    it('Testing', async () => {
    });
  });
});
