namespace quantum_bomb_tester {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    @EntryPoint()
    operation Run(n : Int, iterations : Int) : Unit {

        mutable wins = 0;

        for i in 1..iterations {
            use (qubit1, qubit2) = (Qubit(), Qubit());

            mutable result = [Zero, size = n];
            for j in 0..n-2 {
                Rx(PI()/IntAsDouble(n), qubit1);
                CNOT(qubit1, qubit2);
                let c1 = M(qubit2);
                set result w/= j <- M(qubit2);
                Reset(qubit2);
            }

            set result w/= n-1 <- M(qubit1);
            Reset(qubit1);

            let allZeroes = All(r -> r == Zero, result);
            if (allZeroes) {
                set wins += 1;
            }
        }

        Message($"Won: {IntAsDouble(wins)*100.0/IntAsDouble(iterations)}%");
    }
}