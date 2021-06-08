import {Component, OnInit} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from "@angular/forms";
import {Router} from "@angular/router";
import {UserService} from "../../services/user/user.service";
import {StorageService} from "../../services/storage/storage.service";

@Component({
  selector: 'app-register',
  templateUrl: './register.component.html',
  styleUrls: ['./register.component.scss']
})
export class RegisterComponent implements OnInit {
  form!: FormGroup;
  registerError: boolean;
  registerErrorMessage: string;

  constructor(private router: Router,
              private userService: UserService,
              private storage: StorageService,
              public formBuilder: FormBuilder) {
    this.registerError = false;
    this.registerErrorMessage = "";
  }

  ngOnInit(): void {
    this.form = this.formBuilder.group({
      username: ['', Validators.required],
      password: ['', Validators.required],
    });
  }

  register() {
    let user = this.form.value
    this.userService.registerUser(user).subscribe((res: any) => {
        if (res !== undefined && res !== null) {
          this.registerError = false;
          this.registerErrorMessage = "";

          this.storage.setDataInLocalStorage('id', res.id)
          this.storage.setDataInLocalStorage('username', res.username)

          this.router.navigate(['dashboard/symptoms']);
        }
      },
      error => {
        this.registerError = true;
        this.registerErrorMessage = error.message;
      });
  }

  moveToLoginView() {
    this.router.navigate(["./login"]);
  }

}
