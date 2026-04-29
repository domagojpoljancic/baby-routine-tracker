import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.WatchUi;

const MANUAL_DRAG_MIN_STEP_PX = 18;

class ManualAddFlow {

    static function openTimeSelector(typeCode, popCountAfterAccept) {
        var state = new ManualTimeState(typeCode, popCountAfterAccept);
        var view = new ManualTimeStepView(state, :hour);
        WatchUi.pushView(
            view,
            new ManualTimeStepDelegate(state, view, :hour),
            WatchUi.SLIDE_UP
        );
    }
}

class ManualFeedingTypeDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();

        if (id == :manualFeedLeft) {
            HapticHelper.subtleActionPulse();
            ManualAddFlow.openTimeSelector(1, 2);
            return;
        }
        if (id == :manualFeedBottle) {
            HapticHelper.subtleActionPulse();
            ManualAddFlow.openTimeSelector(3, 2);
            return;
        }
        if (id == :manualFeedRight) {
            HapticHelper.subtleActionPulse();
            ManualAddFlow.openTimeSelector(2, 2);
            return;
        }

        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class ManualTimeState {

    var typeCode;
    var popCountAfterAccept;
    var hour;
    var minute;
    var amPm;
    var didAdd;

    function initialize(entryTypeCode, popCount) {
        typeCode = entryTypeCode;
        popCountAfterAccept = popCount;
        didAdd = false;

        var nowInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        if (System.getDeviceSettings().is24Hour) {
            hour = nowInfo.hour;
            amPm = 0;
        } else {
            hour = _to12Hour(nowInfo.hour);
            amPm = nowInfo.hour < 12 ? 0 : 1;
        }
        minute = nowInfo.min;
    }

    function adjust(step, delta) {
        if (step == :hour) {
            hour += delta;
            if (hour < _minHour()) {
                hour = _minHour();
            }
            if (hour > _maxHour()) {
                hour = _maxHour();
            }
        } else if (step == :minute) {
            _adjustMinute(delta);
        } else if (step == :ampm) {
            amPm += delta;
        }

        _clamp();
    }

    function timestamp() {
        _clamp();
        var hour24 = _hour24();
        var selected = Time.today().value() +
            (hour24 * Time.Gregorian.SECONDS_PER_HOUR) +
            (minute * Time.Gregorian.SECONDS_PER_MINUTE);
        var now = Time.now().value();
        if (selected > now) {
            return now;
        }
        return selected;
    }

    function timeLabel() {
        _clamp();
        var minText = _pad2(minute);
        if (System.getDeviceSettings().is24Hour) {
            return _pad2(hour) + ":" + minText;
        }

        var suffix = amPm == 0 ? " AM" : " PM";
        return hour.toString() + ":" + minText + suffix;
    }

    function valueLabel(step, value) {
        if (step == :hour) {
            if (System.getDeviceSettings().is24Hour) {
                return _pad2(value);
            }
            return value.toString();
        }
        if (step == :ampm) {
            return value == 0 ? "AM" : "PM";
        }
        return _pad2(value);
    }

    function currentStepValue(step) {
        if (step == :hour) {
            return hour;
        }
        if (step == :ampm) {
            return amPm;
        }
        return minute;
    }

    function nextStep(step) {
        if (step == :hour) {
            return :minute;
        }
        if (step == :minute && !System.getDeviceSettings().is24Hour) {
            return :ampm;
        }
        return null;
    }

    function stepTitle(step) {
        if (step == :hour) {
            return "Set Hours";
        }
        if (step == :ampm) {
            return "Set AM/PM";
        }
        return "Set Minutes";
    }

    function previewValue(step, delta) {
        if (step == :hour) {
            var h = hour + delta;
            if (h < _minHour() || h > _maxHour()) {
                return null;
            }
            if (_isFuture(h, minute, amPm)) {
                return null;
            }
            return h;
        }

        if (step == :minute) {
            var preview = _minuteAfter(delta);
            if (preview == null) {
                return null;
            }
            return preview;
        }

        var nextAmPm = amPm + delta;
        if (nextAmPm < 0 || nextAmPm > _maxAmPm()) {
            return null;
        }
        if (_isFuture(hour, minute, nextAmPm)) {
            return null;
        }
        return nextAmPm;
    }

    function _clamp() {
        if (amPm < 0) {
            amPm = 0;
        }
        if (amPm > _maxAmPm()) {
            amPm = _maxAmPm();
        }
        if (hour < _minHour()) {
            hour = _minHour();
        }
        if (hour > _maxHour()) {
            hour = _maxHour();
        }
        if (minute < 0) {
            minute = 0;
        }
        if (minute > _maxMinute()) {
            minute = _maxMinute();
        }
        if (_isFuture(hour, minute, amPm)) {
            _setToNow();
        }
    }

    function _adjustMinute(delta) {
        var candidate = _minuteCandidate(delta);
        if (candidate == null) {
            return;
        }

        hour = candidate[0];
        minute = candidate[1];
        amPm = candidate[2];
    }

    function _minuteAfter(delta) {
        var candidate = _minuteCandidate(delta);
        if (candidate == null) {
            return null;
        }

        return candidate[1];
    }

    function _minuteCandidate(delta) {
        var nowInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var nowMinutes = nowInfo.hour * 60 + nowInfo.min;
        var candidateMinutes = _hour24() * 60 + minute + delta;

        if (candidateMinutes < 0 || candidateMinutes > nowMinutes) {
            return null;
        }

        var candidateHour24 = candidateMinutes / 60;
        var candidateMinute = candidateMinutes % 60;
        if (System.getDeviceSettings().is24Hour) {
            return [candidateHour24, candidateMinute, 0];
        }

        var candidateAmPm = candidateHour24 < 12 ? 0 : 1;
        return [_to12Hour(candidateHour24), candidateMinute, candidateAmPm];
    }

    function _currentHour() {
        return Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).hour;
    }

    function _currentMinute() {
        return Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).min;
    }

    function _maxMinute() {
        if (_hour24() >= _currentHour()) {
            return _currentMinute();
        }
        return 59;
    }

    function _minHour() {
        if (System.getDeviceSettings().is24Hour) {
            return 0;
        }
        return 1;
    }

    function _maxHour() {
        if (System.getDeviceSettings().is24Hour) {
            return _currentHour();
        }

        return 12;
    }

    function _maxAmPm() {
        if (System.getDeviceSettings().is24Hour) {
            return 0;
        }

        return _currentAmPm();
    }

    function _hour24() {
        return _hour24For(hour, amPm);
    }

    function _hour24For(hourValue, amPmValue) {
        if (System.getDeviceSettings().is24Hour) {
            return hourValue;
        }
        if (amPmValue == 0 && hourValue == 12) {
            return 0;
        }
        if (amPmValue == 1 && hourValue < 12) {
            return hourValue + 12;
        }
        return hourValue;
    }

    function _currentAmPm() {
        return _currentHour() < 12 ? 0 : 1;
    }

    function _isFuture(hourValue, minuteValue, amPmValue) {
        var selectedMinutes = _hour24For(hourValue, amPmValue) * 60 + minuteValue;
        var nowMinutes = _currentHour() * 60 + _currentMinute();
        return selectedMinutes > nowMinutes;
    }

    function _setToNow() {
        var nowInfo = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        if (System.getDeviceSettings().is24Hour) {
            hour = nowInfo.hour;
            amPm = 0;
        } else {
            hour = _to12Hour(nowInfo.hour);
            amPm = nowInfo.hour < 12 ? 0 : 1;
        }
        minute = nowInfo.min;
    }

    function _to12Hour(hour24) {
        if (hour24 == 0) {
            return 12;
        }
        if (hour24 > 12) {
            return hour24 - 12;
        }
        return hour24;
    }

    function _pad2(value) {
        if (value < 10) {
            return "0" + value.toString();
        }
        return value.toString();
    }
}

class ManualTimeStepView extends WatchUi.View {

    var _state;
    var _step;

    function initialize(state, step) {
        View.initialize();
        _state = state;
        _step = step;
    }

    function setStep(step) {
        _step = step;
    }

    function onUpdate(dc) {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var cx = w / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(
            cx,
            h * 19 / 100,
            Graphics.FONT_SMALL,
            _state.stepTitle(_step),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        dc.drawLine(w * 22 / 100, h * 26 / 100, w * 78 / 100, h * 26 / 100);

        var metrics = _timeMetrics(dc, w);
        var previewX = metrics["activeCenter"];
        _drawPreview(dc, previewX, h * 39 / 100, 1);
        _drawMainValue(dc, w, h, metrics);
        _drawPreview(dc, previewX, h * 76 / 100, -1);
        _drawConfirmAffordance(dc, w, h);
    }

    function _drawPreview(dc, x, y, delta) {
        var value = _state.previewValue(_step, delta);
        if (value == null) {
            return;
        }

        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.drawText(
            x,
            y,
            Graphics.FONT_TINY,
            _state.valueLabel(_step, value),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    function _drawMainValue(dc, w, h, metrics) {
        var font = metrics["font"];
        var y = h * 58 / 100;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        _drawTimeSegment(
            dc,
            metrics["hourCenter"],
            y,
            font,
            _state.valueLabel(:hour, _state.currentStepValue(:hour)),
            _step == :hour
        );
        dc.drawText(
            metrics["colonCenter"],
            y,
            font,
            ":",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
        _drawTimeSegment(
            dc,
            metrics["minuteCenter"],
            y,
            font,
            _state.valueLabel(:minute, _state.currentStepValue(:minute)),
            _step == :minute
        );

        if (!System.getDeviceSettings().is24Hour) {
            _drawTimeSegment(
                dc,
                metrics["ampmCenter"],
                y,
                Graphics.FONT_SMALL,
                _state.valueLabel(:ampm, _state.currentStepValue(:ampm)),
                _step == :ampm
            );
        }
    }

    function _drawTimeSegment(dc, x, y, font, text, isActive) {
        dc.drawText(
            x,
            y,
            font,
            text,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        if (isActive) {
            dc.drawText(
                x + 1,
                y,
                font,
                text,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
        }
    }

    function _timeMetrics(dc, w) {
        var font = _mainFontFor(dc, w, _state.timeLabel());
        var gap = w * 7 / 100;
        if (gap < 18) {
            gap = 18;
        }
        if (gap > 30) {
            gap = 30;
        }

        var colonW = dc.getTextWidthInPixels(":", font);
        var hourText = _state.valueLabel(:hour, _state.currentStepValue(:hour));
        var minuteText = _state.valueLabel(:minute, _state.currentStepValue(:minute));
        var hourW = dc.getTextWidthInPixels(hourText, font);
        var minuteW = dc.getTextWidthInPixels(minuteText, font);

        var colonCenter = w / 2;
        var hourCenter = colonCenter - gap - colonW / 2 - hourW / 2;
        var minuteCenter = colonCenter + gap + colonW / 2 + minuteW / 2;
        var ampmCenter = 0;
        if (!System.getDeviceSettings().is24Hour) {
            var ampmText = _state.valueLabel(:ampm, _state.currentStepValue(:ampm));
            var ampmW = dc.getTextWidthInPixels(ampmText, Graphics.FONT_SMALL);
            var ampmGap = gap * 2 / 3;
            if (ampmGap < 10) {
                ampmGap = 10;
            }

            var totalW = hourW + gap + colonW + gap + minuteW + ampmGap + ampmW;
            var left = (w - totalW) / 2;
            hourCenter = left + hourW / 2;
            colonCenter = left + hourW + gap + colonW / 2;
            minuteCenter = left + hourW + gap + colonW + gap + minuteW / 2;
            ampmCenter = left + hourW + gap + colonW + gap + minuteW + ampmGap + ampmW / 2;
        }

        var activeCenter = hourCenter;
        if (_step == :minute) {
            activeCenter = minuteCenter;
        } else if (_step == :ampm) {
            activeCenter = ampmCenter;
        }

        return {
            "font" => font,
            "hourCenter" => hourCenter,
            "colonCenter" => colonCenter,
            "minuteCenter" => minuteCenter,
            "ampmCenter" => ampmCenter,
            "activeCenter" => activeCenter
        };
    }

    function _drawConfirmAffordance(dc, w, h) {
        var x = w * 84 / 100;
        var y = h * 32 / 100;
        var size = w * 7 / 100;
        if (size < 14) {
            size = 14;
        }
        if (size > 22) {
            size = 22;
        }

        // Simple check only; the system clock's full circular affordance is not available to CIQ apps.
        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        _drawCheckStroke(dc, x - size / 2, y, x - size / 8, y + size / 3);
        _drawCheckStroke(dc, x - size / 8, y + size / 3, x + size / 2, y - size / 2);
    }

    function _drawCheckStroke(dc, x1, y1, x2, y2) {
        dc.drawLine(x1, y1, x2, y2);
        dc.drawLine(x1 + 1, y1, x2 + 1, y2);
        dc.drawLine(x1, y1 + 1, x2, y2 + 1);
    }

    function _mainFontFor(dc, w, text) {
        var maxW = w * 84 / 100;
        if (dc.getTextWidthInPixels(text, Graphics.FONT_NUMBER_MEDIUM) <= maxW) {
            return Graphics.FONT_NUMBER_MEDIUM;
        }
        return Graphics.FONT_MEDIUM;
    }
}

class ManualTimeStepDelegate extends WatchUi.BehaviorDelegate {

    var _state;
    var _view;
    var _step;
    var _dragY;
    var _dragActive;

    function initialize(state, view, step) {
        BehaviorDelegate.initialize();
        _state = state;
        _view = view;
        _step = step;
        _dragY = null;
        _dragActive = false;
    }

    function onKey(keyEvent) {
        var key = keyEvent.getKey();
        if (key == WatchUi.KEY_UP) {
            _applyScrollNow(-1);
            return true;
        }
        if (key == WatchUi.KEY_DOWN) {
            _applyScrollNow(1);
            return true;
        }
        if (key == WatchUi.KEY_ENTER) {
            _acceptStep();
            return true;
        }
        if (key == WatchUi.KEY_ESC) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            return true;
        }
        return false;
    }

    function onSwipe(swipeEvent) {
        var dir = swipeEvent.getDirection();
        if (dir == WatchUi.SWIPE_UP) {
            _applyScrollNow(1);
            return true;
        }
        if (dir == WatchUi.SWIPE_DOWN) {
            _applyScrollNow(-1);
            return true;
        }
        return false;
    }

    function onDrag(dragEvent) {
        var coords = dragEvent.getCoordinates();
        var y = coords[1];
        var type = dragEvent.getType();

        if (type == WatchUi.DRAG_TYPE_START || _dragY == null) {
            _dragY = y;
            _dragActive = true;
            return true;
        }

        if (type == WatchUi.DRAG_TYPE_STOP) {
            _dragY = null;
            _dragActive = false;
            return true;
        }

        var threshold = System.getDeviceSettings().screenHeight / 14;
        if (threshold < MANUAL_DRAG_MIN_STEP_PX) {
            threshold = MANUAL_DRAG_MIN_STEP_PX;
        }

        var diff = y - _dragY;
        if (diff >= threshold) {
            var stepsDown = _stepsForDragDistance(diff, threshold);
            _dragY += threshold * stepsDown;
            _applyScrollNow(0 - stepsDown);
            return true;
        }

        if (diff <= 0 - threshold) {
            var stepsUp = _stepsForDragDistance(0 - diff, threshold);
            _dragY -= threshold * stepsUp;
            _applyScrollNow(stepsUp);
            return true;
        }

        return true;
    }

    function onTap(clickEvent) {
        var c = clickEvent.getCoordinates();
        var x = c[0];
        var y = c[1];
        var ds = System.getDeviceSettings();
        if (_isConfirmTap(x, y, ds)) {
            _acceptStep();
            return true;
        }

        if (!System.getDeviceSettings().is24Hour) {
            if (x < ds.screenWidth * 46 / 100) {
                _setStep(:hour);
            } else if (x < ds.screenWidth * 72 / 100) {
                _setStep(:minute);
            } else {
                _setStep(:ampm);
            }
            return true;
        }

        if (x < ds.screenWidth / 2) {
            _setStep(:hour);
        } else {
            _setStep(:minute);
        }
        return true;
    }

    function _isConfirmTap(x, y, ds) {
        var cx = ds.screenWidth * 84 / 100;
        var cy = ds.screenHeight * 32 / 100;
        var hit = ds.screenWidth * 12 / 100;
        if (hit < 34) {
            hit = 34;
        }

        return x >= cx - hit && x <= cx + hit && y >= cy - hit && y <= cy + hit;
    }

    function _adjust(delta) {
        var before = _state.currentStepValue(_step);
        _state.adjust(_step, delta);
        var after = _state.currentStepValue(_step);
        return after != before;
    }

    function _scrollAdjust(delta) {
        return _adjust(0 - delta);
    }

    function _applyScrollNow(delta) {
        if (_scrollAdjust(delta)) {
            WatchUi.requestUpdate();
            HapticHelper.subtleActionPulse();
        }
    }

    function _stepsForDragDistance(distance, threshold) {
        if (distance >= threshold * 5) {
            return 5;
        }
        if (distance >= threshold * 3) {
            return 3;
        }
        return 1;
    }

    function _setStep(step) {
        if (_step == step) {
            return;
        }

        _step = step;
        _view.setStep(step);
        _dragY = null;
        _dragActive = false;
        HapticHelper.subtleActionPulse();
        WatchUi.requestUpdate();
    }

    function _acceptStep() {
        var nextStep = _state.nextStep(_step);
        if (nextStep != null) {
            _setStep(nextStep);
            return;
        }

        if (!_state.didAdd && (new FeedingStore()).appendAt(_state.typeCode, _state.timestamp())) {
            _state.didAdd = true;
            HapticHelper.subtleActionPulse();
        }
        _returnToMainScreen();
    }

    function _returnToMainScreen() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        var i;
        for (i = 0; i < _state.popCountAfterAccept; i += 1) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        WatchUi.requestUpdate();
    }
}
