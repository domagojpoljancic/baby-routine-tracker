// Whether feedings_v1 has at least one entry (feeding or diaper). No schema change.
class OnboardingEligibility {

    function hasAnyEntry() {
        var list = (new FeedingStore()).load();
        if (list == null || list.size() == 0) {
            return false;
        }
        return true;
    }
}
