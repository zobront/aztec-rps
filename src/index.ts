import {
    Fr,
    NotePreimage,
    PXE,
    computeMessageSecretHash,
    createDebugLogger,
    createPXEClient,
    getSandboxAccountsWallets,
    getSchnorrAccount,
    waitForSandbox,
  } from '@aztec/aztec.js';
  import { GrumpkinScalar } from '@aztec/circuits.js';
//   import { RPS } from 'contracts/rps/src/main.nr';

  import { format } from 'util';

  const { PXE_URL = 'http://localhost:8080' } = process.env;

  async function main() {
  ////////////// CREATE THE CLIENT INTERFACE AND CONTACT THE SANDBOX //////////////
      const logger = createDebugLogger('rps');

      // We create PXE client connected to the sandbox URL
      const pxe = createPXEClient(PXE_URL);
      // Wait for sandbox to be ready
      await waitForSandbox(pxe);

      const nodeInfo = await pxe.getNodeInfo();

      logger(format('Aztec Sandbox Info ', nodeInfo));

    ////////////// LOAD SOME ACCOUNTS FROM THE SANDBOX //////////////
    // The sandbox comes with a set of created accounts. Load them
    const accounts = await getSandboxAccountsWallets(pxe);
    const player1 = accounts[0].getAddress();
    const player2 = accounts[1].getAddress();
    logger(`Loaded P1's account at ${player1.toShortString()}`);
    logger(`Loaded P2's account at ${player2.toShortString()}`);

    ////////////// DEPLOY OUR TOKEN CONTRACT //////////////

    // logger(`Deploying rock paper scissors contract...`);
    // const contract = await RPS.deploy(pxe).send().deployed();
    // logger(`Contract successfully deployed at address ${contract.address.toShortString()}`);

    // // Create the contract abstraction and link to player 1's wallet for future signing
    // const tokenContractP1 = await RPS.at(contract.address, accounts[0]);
    // const tokenContractP2 = await RPS.at(contract.address, accounts[1]);

    // ////////////// CREATE A NEW GAME //////////////

    // await tokenContractP1.methods.challenge(player2, 0, 1);
  }

  main();
