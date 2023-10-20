import { AztecAddress, ContractBase, ContractFunctionInteraction, ContractMethod, DeployMethod, FieldLike, AztecAddressLike, Wallet } from '@aztec/aztec.js';
import { PXE, PublicKey } from '@aztec/types';
import { ContractArtifact } from '@aztec/foundation/abi';
export declare const RPSContractArtifact: ContractArtifact;
/**
 * Type-safe interface for contract RPS;
 */
export declare class RPSContract extends ContractBase {
    private constructor();
    /**
     * Creates a contract instance.
     * @param address - The deployed contract's address.
     * @param wallet - The wallet to use when interacting with the contract.
     * @returns A promise that resolves to a new Contract instance.
     */
    static at(address: AztecAddress, wallet: Wallet): Promise<RPSContract>;
    /**
     * Creates a tx to deploy a new instance of this contract.
     */
    static deploy(pxe: PXE): DeployMethod<RPSContract>;
    /**
     * Creates a tx to deploy a new instance of this contract using the specified public key to derive the address.
     */
    static deployWithPublicKey(pxe: PXE, publicKey: PublicKey): DeployMethod<RPSContract>;
    /**
     * Returns this contract's artifact.
     */
    static get artifact(): ContractArtifact;
    /** Type-safe wrappers for the public methods exposed by the contract. */
    methods: {
        /** _validateAndAddGame(challengee: struct, game_id: field) */
        _validateAndAddGame: ((challengee: AztecAddressLike, game_id: FieldLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** _validateAndUpdateLeaderboard(game_id: field, outcome: field, challengerThrow: field) */
        _validateAndUpdateLeaderboard: ((game_id: FieldLike, outcome: FieldLike, challengerThrow: FieldLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** challenge(challengee: struct, game_id: field, first_throw: field) */
        challenge: ((challengee: AztecAddressLike, game_id: FieldLike, first_throw: FieldLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** challengeeThrow(game_id: field, throw_value: field) */
        challengeeThrow: ((game_id: FieldLike, throw_value: FieldLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** settle(game_id: field, outcome: field) */
        settle: ((game_id: FieldLike, outcome: FieldLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
        /** timeout(game_id: field) */
        timeout: ((game_id: FieldLike) => ContractFunctionInteraction) & Pick<ContractMethod, 'selector'>;
    };
}
//# sourceMappingURL=RPS.d.ts.map