namespace SantasGiftAlarmTester {

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

        Message("");
        Message("******************************");
        Message("");
        Message("Advanced case:");
        AdvancedVariant(n, iterations);
    }

    operation SimpleVariant(iterations : Int) : Unit {
        for working in [false, true] {
            mutable results = [0, size = 4];

            // for not working alarms we should see inconclusive resullt in 100% of cases
            // for working alarms we should see alarm in 50% of cases
            // and in the remianing 50%
            //  - 25% we will see incoclusive (same result as for not working alarm)
            //  - 25% we will detect a working alarm (different result as for not working alarm)
            Message("");
            Message($"Alarm working? {working}");
            for i in 1..iterations {
                use (q_tester, q_alarm) = (Qubit(), Qubit());
                
                H(q_tester);

                // if alarm is working, there is entanglemet between testing photon and the alarm triggering
                if (working) {
                    CNOT(q_tester, q_alarm);
                } else {
                    I(q_tester);
                }

                H(q_tester);

                let detector = M(q_tester) == One;
                let alarmTriggered = M(q_alarm) == One;
                
                // |00⟩ - inconclusive, Santa did not catch us
                if (not detector and not alarmTriggered) {
                    set results w/= 0 <- results[0]+1;
                }

                // |01⟩ - inconclusive, Santa alerted
                if (not detector and alarmTriggered) {
                    set results w/= 1 <- results[1]+1;
                }

                // |10⟩ - working alarm detected, Santa did not catch us
                if (detector and not alarmTriggered) {
                    set results w/= 2 <- results[2]+1;
                }

                // |11⟩ - working alarm detected, Santa alerted
                if (detector and alarmTriggered) {
                    set results w/= 3 <- results[3]+1;
                }
            }
            Message($"Alarm triggered: {results[1] + results[3]}");
            Message($"Detector 1: {results[0]}");
            Message($"Detector 2: {results[2]} - working alarm detected safely");
            Message($"{results}");
        }
    }

    operation AdvancedVariant(n : Int, iterations : Int) : Unit {
        mutable wins = 0;

        for i in 1..iterations {
            use (q_tester, q_alarm) = (Qubit(), Qubit());

            mutable result = [Zero, size = n+1];
            for j in 0..n-1 {
                Ry(PI()/IntAsDouble(n), q_tester);
                CNOT(q_tester, q_alarm);
                set result w/= j <- M(q_alarm);
                Reset(q_alarm);
            }

            set result w/= n <- M(q_tester);
            Reset(q_tester);

            let allZeroes = All(r -> r == Zero, result);
            if (allZeroes) {
                set wins += 1;
            }
        }

        Message($"Won: {IntAsDouble(wins)*100.0/IntAsDouble(iterations)}%");
    }
}