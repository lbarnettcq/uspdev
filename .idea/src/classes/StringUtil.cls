public with sharing class StringUtil {
    public static String FormatDateForUI(Date dt) {
        Integer mm = dt.month();
        Integer dd = dt.day();
        Integer yyyy = dt.year();
        String displayValue = dd + ', ' + yyyy;
        if (mm == 1) { return 'Jan ' + displayValue; }
        if (mm == 2) { return 'Feb ' + displayValue; }
        if (mm == 3) { return 'Mar ' + displayValue; }
        if (mm == 4) { return 'Apr ' + displayValue; }
        if (mm == 5) { return 'May ' + displayValue; }
        if (mm == 6) { return 'Jun ' + displayValue; }
        if (mm == 7) { return 'Jul ' + displayValue; }
        if (mm == 8) { return 'Aug ' + displayValue; }
        if (mm == 9) { return 'Sep ' + displayValue; }
        if (mm == 10) { return 'Oct ' + displayValue; }
        if (mm == 11) { return 'Nov ' + displayValue; }
        if (mm == 12) { return 'Dec ' + displayValue; }
        return String.valueOf(dt);
    }

    public static String FormatDollarAmount(Decimal value) {
        if (value == 0) {
            return '<span style="color: #808080; font-style: italic;">USD $0.00</span>';
        }

        if (value < 0) {
            return '<span style="color: #ff0000;">(USD $' + String.valueOf(
                    formatNumberFields(String.valueOf(value).replace('-',''),2)) + ')</span>';
        }
        return 'USD $' + String.valueOf(formatNumberFields(String.valueOf(value),2));
    }

    private static String formatNumberFields(String unformattedValue, Integer scale) {
        String formattedValue = Decimal.valueOf(unformattedValue).setScale(scale).format();
        Integer decimalPlaces;
        String decimalSep = 0.23.format().substring(1, 2);

        if(formattedValue.contains(decimalSep)) {
            decimalPlaces = formattedValue.split('\\' + decimalSep)[1].length();
        } else {
            formattedValue += decimalSep;
            decimalPlaces = 0;
        }

        //Add trailing zeros
        while(decimalPlaces < scale) {
            formattedValue += '0';
            decimalPlaces ++;
        }

        return formattedValue;
    }
}