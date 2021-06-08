import {Component, OnInit} from '@angular/core';
import {StorageService} from "../../services/storage/storage.service";
import {ActivatedRoute, Router} from "@angular/router";

@Component({
  selector: 'app-navigate-menu',
  templateUrl: './navigate-menu.component.html',
  styleUrls: ['./navigate-menu.component.css']
})
export class NavigateMenuComponent implements OnInit {
  isSymptomsButtonActive: boolean;

  constructor(private router: Router,
              private activatedRoute: ActivatedRoute,
              public storage: StorageService) {
    this.isSymptomsButtonActive = false;
  }

  ngOnInit(): void {
  }

  clickSymptomsButton() {
    this.isSymptomsButtonActive = !this.isSymptomsButtonActive;
  }

  viewSymptoms() {
    this.router.navigate(['./symptoms'], {relativeTo: this.activatedRoute});
  }

  addSymptom() {
    this.router.navigate(['./symptoms/create'], {relativeTo: this.activatedRoute});
  }

  // TODO: Call Server logout
  atLogout() {
    localStorage.setItem('instantiatedIntervalMethod', 'true');
    localStorage.clear();
    this.router.navigate(['../login']);
  }

}
