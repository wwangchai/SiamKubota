import { LightningElement, api, track, wire } from 'lwc';
import QuestionWelcome from '@salesforce/apex/FormWelcomeCallQuestion.QuestionWelcome';
import saveAnswers from '@salesforce/apex/FormWelcomeCallQuestion.saveAnswers';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class WelcomeCallForm extends LightningElement {
    @track groupedQuestions = {};
    @track answers = new Map();
    @track isEditing = false;
    @track hasExistingAnswers = false;
    @track isResolve = false;
    @api recordId;

    @wire(QuestionWelcome, { welcomeCallId: '$recordId' })
    wiredQuestions({ error, data }) {
        if (data) {
            const grouped = {};
            this.answers = new Map();
            this.hasExistingAnswers = false;
            this.isResolve = data.some(q => q.isResolve);
            data.forEach(q => {
                const section = q.section || 'ทั่วไป';
                const answerType = q.answerType || '';
                const answerValues = q.answerValues || '';
                const rawAnswer = q.answer || '';
                const trimmedAnswer = rawAnswer.trim();
                const setField = q.isFullWidth;
                console.log
                if (trimmedAnswer) {
                    this.hasExistingAnswers = true;
                }
                console.log('Data q:', q);
                const isPicklist = answerType === 'Picklist';
                const isMultiPicklist = answerType === 'Multi Picklist';
                const parsedAnswer = isMultiPicklist
                    ? (trimmedAnswer ? trimmedAnswer.split(',').map(v => v.trim()) : [])
                    : trimmedAnswer;

                const question = {
                    id: q.questionId,
                    label: q.label,
                    isPicklist,
                    isMultiPicklist,
                    isText: answerType === 'Text',
                    isURL: answerType === 'URL',
                    isNumber: answerType === 'Number',
                    isDate: answerType === 'Date',          // ✅ Date
                    isDateTime: answerType === 'Date/Time',  // ✅ Datetime
                    picklistOptions: this.getPicklistOptions(answerValues),
                    answerValue: parsedAnswer,
                    colClass: setField,
                    disble: q.IsDisable
                };


                this.answers.set(q.questionId, parsedAnswer);

                if (!grouped[section]) {
                    grouped[section] = [];
                }
                grouped[section].push(question);
            });

            this.groupedQuestions = grouped;
        } else {
            console.error('Error loading questions:', error);
        }
    }

    get groupedSections() {
        return Object.keys(this.groupedQuestions).map(section => ({
            sectionName: section,
            questions: this.groupedQuestions[section]
        }));
    }

    getPicklistOptions(valueString) {
        if (!valueString) return [{ label: '--None--', value: '' }];
        return [
            { label: '--None--', value: '' },
            ...valueString
                .split(/\r?\n/)                      // แยกบรรทัด
                .map(val => val.trim())              // ตัดช่องว่างหัว-ท้าย
                .filter(val => val !== '')           // กรองค่าที่ว่างเปล่าออก
                .map(val => ({ label: val, value: val }))
        ];
    }

    getColClass(question) {
        return question.isFullWidth
            ? 'slds-col slds-size_1-of-1 slds-p-around_small'
            : 'slds-col slds-size_1-of-1 slds-medium-size_1-of-2 slds-p-around_small';
    }

    handleSingleSelectChange(event) {
        const questionId = event.target.dataset.id;
        const value = event.target.value.trim();
        this.answers.set(questionId, value);

        for (const section of Object.values(this.groupedQuestions)) {
            const question = section.find(q => q.id === questionId);
            if (question) {
                question.answerValue = value;
                break;
            }
        }
    }

    handleDateChange(event) {
        const questionId = String(event.target.dataset.id);
        const value = event.target.value; // yyyy-MM-dd
        this.answers.set(questionId, value);

        for (const section of Object.values(this.groupedQuestions)) {
            const question = section.find(q => String(q.id) === questionId);
            if (question) {
                question.answerValue = value;
                break;
            }
        }
    }

    handleDateTimeChange(event) {
        const questionId = String(event.target.dataset.id);
        const value = event.target.value; // yyyy-MM-ddTHH:mm
        this.answers.set(questionId, value);
        console.log('Selected datetime:', value);
        for (const section of Object.values(this.groupedQuestions)) {
            const question = section.find(q => String(q.id) === questionId);
            if (question) {
                question.answerValue = value;
                break;
            }
        }
    }


    handleNumberChange(event) {
        const questionId = String(event.target.dataset.id); // ให้เป็น string
        const value = event.target.value; // string จาก number input
        this.answers.set(questionId, value);

        for (const section of Object.values(this.groupedQuestions)) {
            const question = section.find(q => String(q.id) === questionId);
            if (question) {
                question.answerValue = value;
                break;
            }
        }
    }

    handleMultiSelectChange(event) {
        const questionId = event.target.dataset.id;
        const values = event.detail.value.map(v => v.trim());
        this.answers.set(questionId, values);

        for (const section of Object.values(this.groupedQuestions)) {
            const question = section.find(q => q.id === questionId);
            if (question) {
                question.answerValue = values;
                break;
            }
        }
    }

    handleTextChange(event) {
        const questionId = event.target.dataset.id;
        const value = event.target.value.trim();
        this.answers.set(questionId, value);

        for (const section of Object.values(this.groupedQuestions)) {
            const question = section.find(q => q.id === questionId);
            if (question) {
                question.answerValue = value;
                break;
            }
        }
    }

    handleURLChange(event) {
        const questionId = event.target.dataset.id;
        const value = event.target.value.trim();
        this.answers.set(questionId, value);

        for (const section of Object.values(this.groupedQuestions)) {
            const question = section.find(q => q.id === questionId);
            if (question) {
                question.answerValue = value;
                break;
            }
        }
    }

    get hasQuestions() {
        if (!this.groupedSections || this.groupedSections.length === 0) {
            return false;
        }
        // เช็คว่ามี questions ภายใน section อย่างน้อย 1 อัน
        return this.groupedSections.some(section => section.questions && section.questions.length > 0);
    }

    handleEdit() {
        this.isEditing = true;
    }

    handleSave() {
        let allAnswers = [];

        this.answers.forEach((value, key) => {
            const formattedValue = Array.isArray(value) ? value.join(',') : value;
            allAnswers.push(`${key}:${formattedValue}`);
        });

        // this.groupedSections.forEach(section => {
        //     section.questions.forEach(q => {
        //         answers.push({
        //             questionId: q.id, 
        //             label: q.label,          // ✅ เก็บ label มาด้วย
        //             answer: q.answerValue,
        //             sectionName: section.sectionName // จะเก็บ section ด้วยก็ได้
        //         });
        //     });
        // });
        // console.log('🚀 Sending answers with label:', answers);

        const answerString = allAnswers.join(';');
        const payload = {
            Answer_Value_All__c: answerString
        };

        saveAnswers({ welcomeCallId: this.recordId, answers: payload })
            .then(() => {
                this.isEditing = false;
                this.hasExistingAnswers = true;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'บันทึกคำตอบเรียบร้อยแล้ว',
                        variant: 'success'
                    })
                );
            })
            .catch(error => {
                console.error('Error saving answers:', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'เกิดข้อผิดพลาดในการบันทึกคำตอบ',
                        variant: 'error'
                    })
                );
            });
    }
}