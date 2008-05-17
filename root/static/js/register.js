function Register() {

    this.EmailInput = function(id, origtext) {
        var emailinput  = this;
        this.input      = jQuery(document.getElementById(id));
        this.origtext   = origtext;

        this.getText = function() {
            var value = jQuery(this.input).val();
            return value;
        }

        this.setText = function(text) {
            if (!text) text = '';
            jQuery(this.input).val(text);
        }

        this.onfocus = function() {
            var value = emailinput.getText();
            if (value == emailinput.origtext) {
                emailinput.setText('');
            }
            return false;
        }

        this.onblur = function() {
            var text = emailinput.getText();
            if (text.length == 0 || text == emailinput.origtext) {
                emailinput.setText(emailinput.origtext);
            }
            return false;
        }

        jQuery(this.input).focus(this.onfocus);
        jQuery(this.input).blur(this.onblur);
    }
    
    this.DatePicker = function(id) {
        jQuery.datepicker.regional['no'] = {
            clearText: 'Tøm',
            clearStatus: '',
            closeText: 'Lukk',
            closeStatus: '',
            prevText: '&laquo;Forrige',
            prevStatus: '',
            nextText: 'Neste&raquo;',
            nextStatus: '',
            currentText: 'I dag',
            currentStatus: '',
            monthNames: ['Januar','Februar','Mars','April','Mai','Juni', 
                'Juli','August','September','Oktober','November','Desember'
            ],
            monthNamesShort: ['Jan','Feb','Mar','Apr','Mai','Jun', 
                'Jul','Aug','Sep','Okt','Nov','Des'
            ],
            monthStatus: '',
            yearStatus: '',
            weekHeader: 'Uke',
            weekStatus: '',
            dayNamesShort: ['Søn','Man','Tir','Ons','Tor','Fre','Lør'],
            dayNames: ['Søndag','Mandag','Tirsdag','Onsdag','Torsdag','Fredag','Lørdag'],
            dayNamesMin: ['Sø','Ma','Ti','On','To','Fr','Lø'],
            dayStatus: 'DD',
            dateStatus: 'D, M d',
            dateFormat: 'yy-mm-dd',
            firstDay: 0,
            initStatus: '',
            isRTL: false
        };
        jQuery.datepicker.setDefaults($.datepicker.regional['no']);
        
        var date_elm = document.getElementById(id);
        
        jQuery(date_elm).datepicker();
        jQuery(date_elm).datepicker({defaultDate: +7});
    }
}

