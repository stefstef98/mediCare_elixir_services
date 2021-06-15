import {Component, OnInit} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from "@angular/forms";
import {Router} from "@angular/router";
import {StorageService} from "../../../../services/storage/storage.service";
import {SymptomService} from "../../../../services/symptom/symptom.service";

@Component({
  selector: 'app-symptom-create',
  templateUrl: './symptom-create.component.html',
  styleUrls: ['./symptom-create.component.css']
})
export class SymptomCreateComponent implements OnInit {
  form!: FormGroup;
  submitError: boolean;
  submitErrorMessage: string;

  constructor(private symptomService: SymptomService,
              private storage: StorageService,
              private router: Router,
              public formBuilder: FormBuilder) {
    this.submitError = false;
    this.submitErrorMessage = "";
  }

  ngOnInit(): void {
    this.form = this.formBuilder.group({
      username: ['', Validators.required],
      password: ['', Validators.required],
      firstName: ['', Validators.required],
      lastName: ['', Validators.required],
      email: ['', Validators.required],
    });
  }

  createSymptom() {
    let symptom = this.form.value
    this.symptomService.createSymptom(symptom).subscribe((res: any) => {
        if (res !== undefined && res !== null) {
          this.submitError = false;
          this.submitErrorMessage = "";

          this.router.navigate(['dashboard/symptoms']);
        }
      },
      error => {
        this.submitError = true;
        this.submitErrorMessage = error.message;
      });
  }

  moveToLoginView() {
    this.router.navigate(["./login"]);
  }

}
