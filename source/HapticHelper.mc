import Toybox.Attention;

// Lightweight, safe haptic pulse for confirmed user actions.
class HapticHelper {

    static function subtleActionPulse() {
        if (Attention has :vibrate && Attention has :VibeProfile) {
            // Short, low-intensity feedback that feels like a native tick.
            var vibe = new Attention.VibeProfile(25, 30);
            Attention.vibrate([vibe]);
        }
    }
}
