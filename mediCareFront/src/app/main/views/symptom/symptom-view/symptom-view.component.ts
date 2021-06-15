import {Component, OnInit} from '@angular/core';
import {Symptom} from "../../../../models/symptom";
import {SymptomService} from "../../../../services/symptom/symptom.service";

@Component({
  selector: 'app-symptom-view',
  templateUrl: './symptom-view.component.html',
  styleUrls: ['./symptom-view.component.css']
})
export class SymptomViewComponent implements OnInit {
  headElements = ['Name', 'Description'];

  public symptoms: Symptom[];
  public noSymptoms: boolean;

  constructor(private symptomService: SymptomService) {
    this.symptoms = [];
    this.noSymptoms = false;
  }

  ngOnInit(): void {
  }

  /**
   * Lifecycle triggered after Angular fully initialized the component's view.
   * Get all Beehive data from the server.
   */
  ngAfterViewInit(): void {
    this.symptomService.getSymtoms().subscribe((data: Symptom[]) => {
      if (data.length === 0) {
        this.noSymptoms = true;
      } else {
        this.symptoms = data;
      }
    });
  }
}
