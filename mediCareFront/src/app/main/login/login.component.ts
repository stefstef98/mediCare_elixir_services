import {Component, OnInit} from '@angular/core';
import {FormBuilder, FormGroup, Validators} from "@angular/forms";
import {Router} from "@angular/router";
import {StorageService} from "../../services/storage/storage.service";
import {UserService} from "../../services/user/user.service";

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent implements OnInit {
  form!: FormGroup;
  loginError: boolean;
  loginErrorMessage: string;

  constructor(private userService: UserService,
              private storage: StorageService,
              private router: Router,
              public formBuilder: FormBuilder) {
    this.loginError = false;
    this.loginErrorMessage = "";
  }

  ngOnInit(): void {
    this.form = this.formBuilder.group({
      username: ['', Validators.required],
      password: ['', Validators.required]
    });
  }

  login() {
    let user = this.form.value
    this.userService.loginUser(user).subscribe((res: any) => {
        if (res !== undefined && res !== null) {
          this.loginError = false;
          this.loginErrorMessage = "";
          this.storage.setDataInLocalStorage('token', res.token)
          // this.storage.setDataInLocalStorage('username', res.username)
        }
      },
      error => {
        this.loginError = true;
        if (error.status === 404) {
          this.loginErrorMessage = "Username/Password combination not found!"
        } else {
          this.loginErrorMessage = error.message;
        }
      },
      () => {
        this.router.navigate(['dashboard/symptoms']);
      });
  }

  moveToRegisterView() {
    this.router.navigate(["./register"]);
  }

}
