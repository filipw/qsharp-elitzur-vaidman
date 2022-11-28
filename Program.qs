namespace quantum_bomb_tester {

    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    @EntryPoint()
    operation Main(n : Int, iterations : Int) : Unit {
        Message("Simple case:");
        SimpleVariant(iterations);

        Message("******************************");
        Message("Advanced case:");
        AdvancedVariant(n, iterations);
    }

    operation SimpleVariant(iterations : Int) : Unit {
        for working in [false, true] {
            mutable results = [0, size = 4];

            // for not working bombs we should see inconclusive resullt in 100% of cases
            // for working bombs we should see explosion in 50% of cases
            // and in the remianing 50%
            //  - 25% we will see incoclusive (same result as for not working bomb)
            //  - 25% we will detect a working bomb (different result as for not working bomb)
            Message("");
            Message($"Bomb working? {working}");
            for i in 1..iterations {
                use (q_tester, q_explosion) = ( Qubit(), Qubit());
                
                H(q_tester);

                // if bomb is working, there is entanglemet between testing photon and the explosion
                if (working) {
                    CNOT(q_tester, q_explosion);
                } else {
                    I(q_tester);
                }

                H(q_tester);

                let detector = M(q_tester) == One;
                let exploded = M(q_explosion) == One;
                
                // |00⟩ - inconclusive
                if (not detector and not exploded) {
                    set results w/= 0 <- results[0]+1;
                }

                // |01⟩ - bomb lost
                if (not detector and exploded) {
                    set results w/= 1 <- results[1]+1;
                }
                
                // |10⟩ - working bomb detected
                if (detector and not exploded) {
                    set results w/= 2 <- results[2]+1;
                }
                
                // |11⟩ - bomb lost
                if (detector and exploded) {
                    set results w/= 3 <- results[3]+1;
                }
            }
            Message($"Exploded: {results[1] + results[3]}");
            Message($"Detector 1: {results[0]}");
            Message($"Detector 2: {results[2]} - working bomb detected");
            Message($"{results}");
        }
    }

    operation AdvancedVariant(n : Int, iterations : Int) : Unit {
        mutable wins = 0;

        for i in 1..iterations {
            use (qubit1, qubit2) = (Qubit(), Qubit());

            mutable result = [Zero, size = n];
            for j in 0..n-2 {
                Rx(PI()/IntAsDouble(n), qubit1);
                CNOT(qubit1, qubit2);
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