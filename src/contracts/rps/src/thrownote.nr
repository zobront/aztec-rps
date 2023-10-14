use dep::std::hash::pedersen;
use dep::aztec::{
    context::{PrivateContext, PublicContext, Context},
    note::{
        note_header::NoteHeader,
        note_interface::NoteInterface,
        utils::compute_note_hash_for_read_or_nullify
    },
    types::address::AztecAddress,
    hash::compute_secret_hash,
    oracle::{
        rand::rand,
        get_secret_key::get_secret_key
    }
};

global THROW_NOTE_LEN: Field = 3;

struct ThrowNote {
    choice: Field,
    owner: Field,
    randomness: Field,
    header: NoteHeader,
}

impl ThrowNote {

    pub fn new(choice: Field, owner: Field) -> Self {
        let randomness = rand();
        ThrowNote {
            choice,
            owner,
            randomness,
            header: NoteHeader::empty(),
        }
    }

    // STANDARD NOTE_INTERFACE FUNCTIONS

    pub fn serialize(self) -> [Field; THROW_NOTE_LEN] {
        [self.choice, self.owner, self.randomness]
    }

    pub fn deserialize(preimage: [Field; THROW_NOTE_LEN]) -> Self {
        ThrowNote {
            choice: preimage[0],
            owner: preimage[1],
            randomness: preimage[2],
            header: NoteHeader::empty(),
        }
    }

    pub fn compute_note_hash(self) -> Field {
        dep::std::hash::pedersen([
            self.choice,
            self.owner,
            self.randomness,
        ])[0]
    }

    pub fn compute_nullifier(self) -> Field {
        let note_hash_for_nullify = compute_note_hash_for_read_or_nullify(ThrowNoteMethods, self);
        let secret = get_secret_key(self.owner);
        dep::std::hash::pedersen([
            note_hash_for_nullify,
            secret.low,
            secret.high,
        ])[0]
    }

    pub fn set_header(&mut self, header: NoteHeader) {
        self.header = header;
    }
}

fn deserialize(preimage: [Field; THROW_NOTE_LEN]) -> ThrowNote {
    ThrowNote::deserialize(preimage)
}

fn serialize(note: ThrowNote) -> [Field; THROW_NOTE_LEN] {
    note.serialize()
}

fn compute_note_hash(note: ThrowNote) -> Field {
    note.compute_note_hash()
}

fn compute_nullifier(note: ThrowNote) -> Field {
    note.compute_nullifier()
}

fn get_header(note: ThrowNote) -> NoteHeader {
    note.header
}

fn set_header(note: &mut ThrowNote, header: NoteHeader) {
    note.set_header(header)
}

global ThrowNoteMethods = NoteInterface {
    deserialize,
    serialize,
    compute_note_hash,
    compute_nullifier,
    get_header,
    set_header,
};
