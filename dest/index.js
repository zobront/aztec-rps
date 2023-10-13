import { createDebugLogger, createPXEClient, getSandboxAccountsWallets, waitForSandbox, } from '@aztec/aztec.js';
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
//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJmaWxlIjoiaW5kZXguanMiLCJzb3VyY2VSb290IjoiIiwic291cmNlcyI6WyIuLi9zcmMvaW5kZXgudHMiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUEsT0FBTyxFQUtILGlCQUFpQixFQUNqQixlQUFlLEVBQ2YseUJBQXlCLEVBRXpCLGNBQWMsR0FDZixNQUFNLGlCQUFpQixDQUFDO0FBRTNCLHFEQUFxRDtBQUVuRCxPQUFPLEVBQUUsTUFBTSxFQUFFLE1BQU0sTUFBTSxDQUFDO0FBRTlCLE1BQU0sRUFBRSxPQUFPLEdBQUcsdUJBQXVCLEVBQUUsR0FBRyxPQUFPLENBQUMsR0FBRyxDQUFDO0FBRTFELEtBQUssVUFBVSxJQUFJO0lBQ25CLGlGQUFpRjtJQUM3RSxNQUFNLE1BQU0sR0FBRyxpQkFBaUIsQ0FBQyxLQUFLLENBQUMsQ0FBQztJQUV4QyxvREFBb0Q7SUFDcEQsTUFBTSxHQUFHLEdBQUcsZUFBZSxDQUFDLE9BQU8sQ0FBQyxDQUFDO0lBQ3JDLCtCQUErQjtJQUMvQixNQUFNLGNBQWMsQ0FBQyxHQUFHLENBQUMsQ0FBQztJQUUxQixNQUFNLFFBQVEsR0FBRyxNQUFNLEdBQUcsQ0FBQyxXQUFXLEVBQUUsQ0FBQztJQUV6QyxNQUFNLENBQUMsTUFBTSxDQUFDLHFCQUFxQixFQUFFLFFBQVEsQ0FBQyxDQUFDLENBQUM7SUFFbEQsaUVBQWlFO0lBQ2pFLDhEQUE4RDtJQUM5RCxNQUFNLFFBQVEsR0FBRyxNQUFNLHlCQUF5QixDQUFDLEdBQUcsQ0FBQyxDQUFDO0lBQ3RELE1BQU0sT0FBTyxHQUFHLFFBQVEsQ0FBQyxDQUFDLENBQUMsQ0FBQyxVQUFVLEVBQUUsQ0FBQztJQUN6QyxNQUFNLE9BQU8sR0FBRyxRQUFRLENBQUMsQ0FBQyxDQUFDLENBQUMsVUFBVSxFQUFFLENBQUM7SUFDekMsTUFBTSxDQUFDLDBCQUEwQixPQUFPLENBQUMsYUFBYSxFQUFFLEVBQUUsQ0FBQyxDQUFDO0lBQzVELE1BQU0sQ0FBQywwQkFBMEIsT0FBTyxDQUFDLGFBQWEsRUFBRSxFQUFFLENBQUMsQ0FBQztJQUU1RCx1REFBdUQ7SUFFdkQsdURBQXVEO0lBQ3ZELDREQUE0RDtJQUM1RCwyRkFBMkY7SUFFM0Ysc0ZBQXNGO0lBQ3RGLHVFQUF1RTtJQUN2RSx1RUFBdUU7SUFFdkUsa0RBQWtEO0lBRWxELDBEQUEwRDtBQUM1RCxDQUFDO0FBRUQsSUFBSSxFQUFFLENBQUMifQ==